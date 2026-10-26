#!/usr/bin/env bash
#
# ai-lawbook 가드 훅 — 반성문 장부에 적힌 기계 규칙 줄을 도구 호출과 최종 응답에 집행한다.
#
# 왜 필요한가: 주입된 장부는 읽어도 잊을 수 있다. 같은 위반이 반복되면 장부 항목에 기계가 판정할 수
# 있는 규칙 줄을 적고, 이 훅이 하네스 단계에서 막거나 고친다. 규칙 줄이 없으면 아무것도 하지 않는다.
#
# 장부 항목(## [ 로 시작) 안 어디든, 줄 머리 그대로:
#   - 차단: <정규식>  / - Block: <regex>     PreToolUse(Bash): 따옴표 구간을 지운 명령과 따옴표 기호만 지운
#                                             명령이 둘 다 맞으면 거부. 빈 문자열에도 맞는 정규식은 무시한다
#   - 검사: 한국어    / - Check: korean      PreToolUse(Bash): 한글 없는 description 거부
#                                             Stop·SubagentStop: 코드를 뺀 최종 응답이 라틴 문자 40자 이상인데
#                                             한글이 없으면 한 번 되돌려 다시 쓰게 한다(stop_hook_active 면 통과)
#   - 검사: 비밀값    / - Check: secrets     PostToolUse(Bash): stdout·stderr 의 비밀값을 가려 모델에 넘긴다
# 안내 문구는 규칙 줄을 쓴 언어(한국어 머리/영어 머리)를 따른다. 두 플러그인이 같은 파일을 쓴다.
#
# 사용법: hooks.json 이 PreToolUse·PostToolUse(matcher Bash)·Stop·SubagentStop 에서 인자 없이 부른다.
# 입력은 표준입력의 훅 JSON(hook_event_name 으로 분기)이다.
#
# 실패 정책(fail-open): 장부가 없거나, 규칙 줄이 없거나, jq 가 없거나(또는 --rawfile 이 없는 1.5 이하),
# 입력이 깨졌으면 아무것도 출력하지 않고 exit 0. 가드가 고장 나도 작업을 막지 않는다.
# 원래 비밀값은 어디에도 쓰지 않는다(로그 없음, 바뀐 출력만 낸다).
set -uo pipefail

[ -n "${HOME:-}" ] || exit 0
LEDGER="${HOME}/.claude/ai-lawbook/confessions.md"
[ -r "$LEDGER" ] || exit 0
grep -Eq '^- (차단|Block|검사|Check): ' "$LEDGER" 2>/dev/null || exit 0
command -v jq >/dev/null 2>&1 || exit 0

read -r -d '' PROG <<'JQ'
# 장부 → [{title, fix, block: [{re, ko}], korean, secrets}] (korean·secrets 는 "ko"/"en"/null)
def entries:
  reduce ($ledger | split("\n")[] | rtrimstr("\r")) as $l
    ({fence: false, cur: null, out: []};
     if ($l | test("^\\s*```")) then .fence |= not
     elif .fence then .
     elif ($l | startswith("## [")) then
       .out += [.cur // empty] | .cur = {title: ($l | ltrimstr("## ")), fix: "", block: [], korean: null, secrets: null}
     elif ($l | test("^##? ")) then .out += [.cur // empty] | .cur = null
     elif .cur == null then .
     elif ($l | test("^- (시정 및 재발 방지|Correction and prevention):")) then .cur.fix = ($l | sub("^- [^:]*:\\s*"; ""))
     elif ($l | test("^- (차단|Block): ")) then
       ($l | sub("^- (차단|Block): "; "") | sub("\\s+$"; "")) as $re
       | if $re == "" then . else .cur.block += [{re: $re, ko: ($l | startswith("- 차단"))}] end
     elif ($l | test("^- (검사: 한국어|Check: [Kk]orean)\\s*$")) then .cur.korean = (if ($l | startswith("- 검사")) then "ko" else "en" end)
     elif ($l | test("^- (검사: 비밀값|Check: [Ss]ecrets)\\s*$")) then .cur.secrets = (if ($l | startswith("- 검사")) then "ko" else "en" end)
     else . end)
  | .out + [.cur // empty];

# 비밀값 이름(대소문자 무관): password·passwd·secret·token·api key·private key. 소문자가 이어지거나(tokenizer)
# 복수형이면(max_tokens·SECRETS) 비밀값 이름이 아니다. 앞뒤로 붙은 단어 글자는 키 이름의 일부다.
def secret_key: "[A-Za-z0-9_.-]*(?i:passw(?:or)?d|secret|token|api[_-]?key|private[_-]?key)(?![a-z])(?![Ss](?![A-Za-z0-9]))[A-Za-z0-9_.-]*";

# mask 의 규칙이 걸릴 수 있는 단서. jq 는 정규식을 호출마다 새로 컴파일하므로, 단서가 없는 출력과 줄은
# 규칙 9개를 돌리지 않고 넘긴다(실제 장부 기준 Bash 호출당 63ms → 23ms).
def secret_hint: "-----BEGIN|://\\S*@|(?i:authorization|bearer|passw(?:or)?d|secret|token|api[_-]?key|private[_-]?key)|(sk|rk)[-_]|gh[pousr]_|github_pat_|glpat-|xox[abposr]-|AKIA|ASIA|AIza|eyJ";

# 비밀값을 $t 로 바꾼다. PEM 개인키는 여러 줄이라 먼저 통째로 가리고, 나머지는 줄마다 본다.
# - DSN 의 user:비밀번호@ (user 는 비어도 된다. host:포트/… 는 비밀번호가 아니다), Authorization 헤더 값,
#   Bearer 토큰, 알려진 접두 토큰(sk-·ghp_·xoxb-·AKIA… 단어 중간의 task- 같은 것은 제외), JWT
# - 어디서든 KEY=값, "KEY": "값", --KEY 값
# - 줄 머리(들여쓰기·목록·diff·grep 접두 허용)의 KEY: 값 / KEY = 값 — 값이 함수 호출·첨자 식이면 코드로 보고
#   둔다(`token = get_token()`, `api_key = os.environ["API_KEY"]`).
def mask($t):
  if test(secret_hint) | not then . else
  ("[A-Za-z_$][A-Za-z0-9_.$]*[ \\t]*[(\\[].*[)\\]][ \\t]*[;,]?[ \\t]*$") as $code
  | gsub("(?<b>-----BEGIN [A-Z0-9 ]*PRIVATE KEY-----)[\\s\\S]*?(?<e>-----END [A-Z0-9 ]*PRIVATE KEY-----|\\z)"; "\(.b)\n\($t)\n\(.e)")
  | split("\n") | map(if test(secret_hint) | not then . else
    gsub("(?<p>://[^:/\\s@]*:)(?![0-9]+(/|\\s|$))\\S+?@(?=[^@\\s/]+([/:?#\\s]|$))"; "\(.p)\($t)@")
    | gsub("(?<p>(?i:authorization)[\"']?[ \\t]*[:=][ \\t]*[\"']?([A-Za-z]+[ \\t]+)?)[^\\s\"',]+"; "\(.p)\($t)")
    | gsub("Bearer [A-Za-z0-9._~+/=-]{8,}"; "Bearer \($t)")
    | gsub("(?<![A-Za-z0-9_-])((sk|rk)[-_]|sk_live_|sk_test_|gh[pousr]_|github_pat_|glpat-|xox[abposr]-|AKIA|ASIA|AIza)[A-Za-z0-9_-]{16,}"; $t)
    | gsub("(?<![A-Za-z0-9_-])eyJ[A-Za-z0-9_-]{8,}\\.eyJ[A-Za-z0-9_-]{8,}\\.[A-Za-z0-9_-]*"; $t)
    | gsub("(?<k>\"" + secret_key + "\"[ \\t]*:[ \\t]*)\"[^\"]*\""; "\(.k)\"\($t)\"")
    | gsub("(?<k>" + secret_key + "=)(?!=)(\"[^\"]*\"|'[^']*'|[^\\s\"']+)"; "\(.k)\($t)")
    | gsub("(?<k>--" + secret_key + "[ \\t]+)(?![-<\"'])[^\\s\"']+"; "\(.k)\($t)")
    | sub("^(?<k>([^\\s:]+:([0-9]+:)?)?[-+ ]?[ \\t]*(- )?(export[ \\t]+)?[\"']?" + secret_key + "[\"']?[ \\t]*[:=][ \\t]*)(?!((await|new)[ \\t]+)?" + $code + ")[^ \\t].*$"; "\(.k)\($t)")
  end) | join("\n") end;

# 역슬래시 이스케이프와 따옴표 구간을 지운다. jq 1.7 의 gsub·scan 은 일치 수에 대해 제곱이라(10만 자
# heredoc 명령에 14초, 훅 타임아웃 5초) 한 번 훑는 상태 기계로 한다. 닫히지 않은 따옴표는 끝까지 지운다.
def strip_quotes:
  reduce explode[] as $c ({o: [], q: 0, e: false};
    if .e then .e = false
    elif .q == 39 then (if $c == 39 then .q = 0 else . end)
    elif $c == 92 then .e = true
    elif .q == 34 then (if $c == 34 then .q = 0 else . end)
    elif $c == 39 or $c == 34 then .q = $c
    else .o += [$c] end)
  | .o | implode;

def deny($why): {hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $why}};

entries as $E
# 컴파일되지 않거나 빈 문자열에도 맞는 정규식(`pkill|`, `.*`)은 버린다. 둘 다 모든 명령을 막는 실수다.
| [$E[] | . as $e | .block[] | . as $b | select(try ("" | test($b.re) | not) catch false) | . + {title: $e.title, fix: $e.fix}] as $B
| (first($E[] | .korean // empty) // null) as $KO
| (first($E[] | .secrets // empty) // null) as $SEC
| .hook_event_name as $ev
| if $ev == "PreToolUse" and .tool_name == "Bash" then
    # $unq: 따옴표 기호만 지운 명령. $cmd: 따옴표 구간째 지운 명령(따옴표 안 글자는 데이터라 규칙에 걸리지
    # 않는다). 두 쪽 모두 맞아야 막는다 — `git stash drop "stash@{0}"` 처럼 따옴표 안 글자가 규칙의 예외
    # 조건(부정 전방탐색)을 채우는 경우를 오탐하지 않는다. 싼 $unq 로 먼저 거르고 $cmd 는 후보가 있을 때만 만든다.
    ((.tool_input.command // "") | tostring) as $raw
    | ($raw | explode | map(select(. != 34 and . != 39)) | implode) as $unq
    | [$B[] | . as $b | select(try ($unq | test($b.re)) catch false)] as $cand
    | (if $cand == [] then null
       else ($raw | strip_quotes) as $cmd | first($cand[] | . as $b | select(try ($cmd | test($b.re)) catch false)) // null end) as $hit
    | ((.tool_input.description // "") | tostring) as $desc
    | if $hit then
        ($hit.fix | .[0:200] | sub("[.\\s]+$"; "")) as $fix
        | if $hit.ko then deny("반성문 장부 「\($hit.title)」의 차단 규칙(\($hit.re))에 걸렸다. 재발 방지: \($fix). 규칙을 끄려면 장부에서 그 줄을 지워라.")
          else deny("Blocked by the rule (\($hit.re)) in Confession Ledger entry \"\($hit.title)\". Prevention: \($fix). To turn the rule off, delete that line from the ledger.") end
      elif $KO and ($desc | test("\\S")) and ($desc | test("[가-힣]") | not) then
        if $KO == "ko" then deny("Bash description 을 한국어로 다시 써서 호출하라(반성문 장부 검사: 한국어).")
        else deny("Rewrite the Bash description in Korean and call again (Confession Ledger Check: korean).") end
      else empty end
  elif ($ev == "Stop" or $ev == "SubagentStop") and $KO and .stop_hook_active != true then
    # 앞 2만 자만 본다. gsub·scan 은 일치 수에 대해 제곱이라 긴 응답(10만 자)에 16초가 걸린다(타임아웃 5초).
    ((.last_assistant_message // "") | tostring | .[0:20000]
     | gsub("```[\\s\\S]*?(```|\\z)"; "") | gsub("`[^`\\n]*`"; "")) as $m
    | if ([$m | explode[] | select((. >= 65 and . <= 90) or (. >= 97 and . <= 122))] | length) >= 40
         and ($m | test("[가-힣]") | not) then
        {decision: "block", reason: (if $KO == "ko"
          then "최종 응답에 한국어가 없다. 다른 작업 없이 같은 내용을 한국어로 다시 써라(코드·명령·고유명사만 원문). 사용자가 이번 턴에 영어를 명시 요청했거나 기계 판독용 출력(JSON 등)이면 그대로 다시 내라."
          else "The final response has no Korean. Without doing anything else, rewrite the same content in Korean (keep only code, commands, and proper nouns as is). If the user explicitly asked for English this turn or the output is machine-readable (JSON etc.), output it again unchanged." end)}
      else empty end
  elif $ev == "PostToolUse" and .tool_name == "Bash" and $SEC and (.tool_response | type) == "object" and .tool_response.isImage != true then
    (if $SEC == "ko" then "<가림>" else "<redacted>" end) as $t
    # 있는 문자열 필드만 바꾸고 키를 더하지 않는다. 모양이 원래 출력과 다르면 하네스가 교체를 무시해
    # 가리지 않은 원문이 그대로 모델에 간다(문서: 내장 도구는 출력 스키마가 맞아야 한다).
    | .tool_response as $r
    | ($r | with_entries(if (.key == "stdout" or .key == "stderr") and (.value | type) == "string"
                         then .value |= mask($t) else . end)) as $n
    | if $n != $r then {hookSpecificOutput: {hookEventName: "PostToolUse", updatedToolOutput: $n}} else empty end
  else empty end
JQ

out="$(jq -c --rawfile ledger "$LEDGER" "$PROG" 2>/dev/null)" || exit 0
[ -n "$out" ] && printf '%s\n' "$out"
exit 0
