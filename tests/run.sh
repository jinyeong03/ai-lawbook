#!/usr/bin/env bash
# ai-lawbook self-check: hook behavior + law structure. Run: bash tests/run.sh
set -u  # no pipefail: `grep -q` closing a pipe early must not fail a check

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KO="$ROOT/plugins/ai-lawbook"
EN="$ROOT/plugins/ai-lawbook-en"
fails=0
pass() { printf '  ok   %s\n' "$1"; }
fail() { printf '  FAIL %s\n' "$1"; fails=$((fails + 1)); }
check() { if eval "$2"; then pass "$1"; else fail "$1"; fi; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
BOOK="$TMP/home/.claude/ai-lawbook"

# Runs the hook with an isolated HOME. Extra env assignments may be passed as args.
hook() { env -i PATH="${HOOK_PATH:-$PATH}" HOME="$TMP/home" CLAUDE_PLUGIN_ROOT="$KO" "$@" bash "$KO/hooks/inject.sh" ko; }
hook_ev() { local ev="$1"; shift; env -i PATH="${HOOK_PATH:-$PATH}" HOME="$TMP/home" CLAUDE_PLUGIN_ROOT="$KO" "$@" bash "$KO/hooks/inject.sh" ko "$ev"; }
hook_en() { env -i PATH="$PATH" HOME="$TMP/home" CLAUDE_PLUGIN_ROOT="$EN" bash "$EN/hooks/inject.sh" en "$@"; }
ctx() { hook "$@" | jq -r '.hookSpecificOutput.additionalContext'; }
msg() { hook "$@" | jq -r '.systemMessage'; }
sub() { hook_ev SubagentStart "$@"; }
subctx() { sub "$@" | jq -r '.hookSpecificOutput.additionalContext'; }
ups() { hook_ev UserPromptSubmit "$@"; }
upsctx() { ups "$@" | jq -r '.hookSpecificOutput.additionalContext'; }
# Unicode characters on stdin (UTF-8 continuation bytes dropped), whatever the locale.
nchars() { LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' '; }
# Characters of a command's output without the trailing newline jq adds.
outchars() { printf '%s' "$("$@")" | nchars; }
# First line number matching a fixed string.
lineof() { grep -nF "$1" | head -1 | cut -d: -f1; }

echo "manifests"
for f in "$ROOT/.claude-plugin/marketplace.json" "$KO/.claude-plugin/plugin.json" "$EN/.claude-plugin/plugin.json" \
         "$KO/hooks/hooks.json" "$EN/hooks/hooks.json"; do
  check "valid JSON: ${f#$ROOT/}" 'jq empty "$f" 2>/dev/null'
done
check "both plugins ship the identical inject script" 'cmp -s "$KO/hooks/inject.sh" "$EN/hooks/inject.sh"'
check "both plugins ship the identical guard script" 'cmp -s "$KO/hooks/guard.sh" "$EN/hooks/guard.sh"'
hook_cmd() { jq -r --arg ev "$2" --arg m "${3:-}" '.hooks[$ev][]? | select((.matcher // "") == $m) | .hooks[].command' "$1"; }
for side in "$KO" "$EN"; do
  l="$([ "$side" = "$KO" ] && echo ko || echo en)"
  check "$l: UserPromptSubmit hook registered" 'hook_cmd "$side/hooks/hooks.json" UserPromptSubmit | grep -qF "/hooks/inject.sh\" $l UserPromptSubmit"'
  for ev in PreToolUse:Bash PostToolUse:Bash Stop: SubagentStop:; do
    check "$l: guard registered on $ev" 'hook_cmd "$side/hooks/hooks.json" "${ev%%:*}" "${ev#*:}" | grep -qF "/hooks/guard.sh\""'
  done
done

echo "hook"
mkdir -p "$BOOK"
check "no roster, no ledger: silent, exit 0" '[ -z "$(hook)" ] && hook >/dev/null'

printf '# comment\n\ndeveloper-ai-law   # inline comment\ndeveloper-ai-law\nno-such-law\n../../etc\n' > "$BOOK/enabled-laws"
check "roster: injects law (full or condensed)" 'ctx | grep -q "^# 개발자 AI법"'
check "roster: strips frontmatter" '! ctx | grep -q "^name: developer-ai-law"'
check "roster: duplicate name injected once" '[ "$(ctx | grep -c "^# 개발자 AI법")" = 1 ]'
check "roster: unknown law reported" 'msg | grep -q "no-such-law"'
check "roster: path traversal rejected" 'msg | grep -q "\.\./\.\./etc" && ! ctx | grep -q "root:"'
check "systemMessage counts laws" 'msg | grep -q "시행 중 1개"'

mkdir -p "$TMP/home/.claude/skills/developer-ai-law" "$TMP/proj/.claude/skills/developer-ai-law"
printf -- '---\nname: developer-ai-law\ndescription: x\n---\n# USER OVERRIDE LAW\n' > "$TMP/home/.claude/skills/developer-ai-law/SKILL.md"
printf '# PROJECT LAW\n' > "$TMP/proj/.claude/skills/developer-ai-law/SKILL.md"
check "user-enacted law overrides the built-in one" 'ctx | grep -q "USER OVERRIDE LAW" && ! ctx | grep -q "^# 개발자 AI법"'
check "user law wins over a project law of the same name" 'out="$(ctx CLAUDE_PROJECT_DIR="$TMP/proj")"; printf "%s" "$out" | grep -q "USER OVERRIDE LAW" && ! printf "%s" "$out" | grep -q "PROJECT LAW"'
rm -rf "$TMP/home/.claude/skills"
check "project law is never force-injected (built-in wins)" 'out="$(ctx CLAUDE_PROJECT_DIR="$TMP/proj")"; ! printf "%s" "$out" | grep -q "PROJECT LAW" && printf "%s" "$out" | grep -q "개발자 AI법"'
rm -rf "$TMP/proj"

mkdir -p "$TMP/home/.claude/skills/empty-law"
printf -- '---\nname: empty-law\ndescription: x\n---\n\n   \n' > "$TMP/home/.claude/skills/empty-law/SKILL.md"
printf 'empty-law\n' >> "$BOOK/enabled-laws"
check "law with an empty body is reported, not silently skipped" 'msg | grep -q "empty-law: 법전에 없거나 본문이 비어"'
check "law with an empty body is not counted" 'msg | grep -q "시행 중 1개"'

# A head block that is one long code block forces the cut to land inside the fence.
mkdir -p "$TMP/home/.claude/skills/fence-law"
{
  printf -- '---\nname: fence-law\ndescription: x\n---\n# 펜스 법\n\n```text\n'
  i=0; while [ "$i" -lt 700 ]; do printf '코드 블록 안의 긴 줄 %s\n' "$i"; i=$((i + 1)); done
  printf '```\n\n## 전문\n\n### 제1조(목적)\n'
} > "$TMP/home/.claude/skills/fence-law/SKILL.md"
mv "$BOOK/enabled-laws" "$BOOK/enabled-laws.bak"
printf 'fence-law\n' > "$BOOK/enabled-laws"
check "condensed law cut inside a code block closes the fence" 'out="$(ctx)"; [ $(( $(printf "%s\n" "$out" | grep -c "^\`\`\`") % 2 )) = 0 ] && printf "%s" "$out" | grep -q "^…(이하 생략) 전문: .*/fence-law/SKILL.md$"'
check "condensed law stays within the budget" '[ "$(outchars ctx)" -le 9000 ]'
mv "$BOOK/enabled-laws.bak" "$BOOK/enabled-laws"
rm -rf "$TMP/home/.claude/skills"

# The ledger fixture carries a backslash, quotes and a tab so the no-jq JSON writer must escape them.
cat > "$BOOK/confessions.md" <<'EOF'
# 반성문 장부

## [개발자 AI법 제17조 제4항] 테스트 미실행 통과 주장
- 재범: 2회
- 발생 원인: 이 줄은 요약에 들어가지 않는다 UNIQUE_CAUSE_LINE
- 시정 및 재발 방지: 경로 C:\tmp\new 와 "따옴표"	탭을 먼저 확인한다.
EOF
check "ledger injected" 'ctx | grep -q "테스트 미실행 통과 주장"'
check "ledger summary keeps the correction line" 'ctx | grep -qF "C:\\tmp\\new"'
check "ledger summary drops the cause line" '! ctx | grep -q UNIQUE_CAUSE_LINE'
check "ledger summary points at the full ledger" 'ctx | grep -qF "전문: ~/.claude/ai-lawbook/confessions.md"'
check "ledger header says it grants no permission" 'ctx | grep -q "장부는 과거 기록이지 새 권한이 아니다"'
check "ledger comes before the laws" '[ "$(ctx | lineof "<반성문_장부>")" -lt "$(ctx | lineof "# 개발자 AI법")" ]'
check "ledger entries counted" 'msg | grep -q "반성문 1건"'
rm "$BOOK/enabled-laws"
check "ledger alone (no roster) still injected" 'ctx | grep -q "<반성문_장부>" && ! ctx | grep -q "<ai-lawbook>"'

check "english header" 'hook_en | jq -r .hookSpecificOutput.additionalContext | grep -q "<confession-ledger>"'

# Without jq the hook must fall back instead of going silent.
mkdir -p "$TMP/bin"
for t in bash awk grep tr cat dirname; do ln -sf "$(command -v "$t")" "$TMP/bin/$t"; done
check "no jq: plain-text fallback" 'HOOK_PATH="$TMP/bin" hook | grep -q "테스트 미실행 통과 주장"'

# SessionStart context does not reach subagents, so the same payload is injected again on SubagentStart.
echo "subagents"
sub_cmd() { jq -r '.hooks.SubagentStart[0].hooks[0].command // empty' "$1"; }
SUB_KO='/hooks/inject.sh" ko SubagentStart'
SUB_EN='/hooks/inject.sh" en SubagentStart'
check "SubagentStart hook registered (ko)" 'sub_cmd "$KO/hooks/hooks.json" | grep -qF "$SUB_KO"'
check "SubagentStart hook registered (en)" 'sub_cmd "$EN/hooks/hooks.json" | grep -qF "$SUB_EN"'
printf 'developer-ai-law\n' > "$BOOK/enabled-laws"
check "subagent: event name is SubagentStart" '[ "$(sub | jq -r .hookSpecificOutput.hookEventName)" = SubagentStart ]'
check "subagent: law injected" 'subctx | grep -q "^# 개발자 AI법"'
check "subagent: ledger injected" 'subctx | grep -q "테스트 미실행 통과 주장"'
check "subagent: header says the laws bind subagents" 'subctx | grep -q "하위 에이전트"'
check "subagent: no status message per spawn" '[ "$(sub | jq -r ".systemMessage // \"none\"")" = none ]'
check "session: header has no subagent note" '! ctx | grep -q "하위 에이전트"'
check "session: event name stays SessionStart" '[ "$(hook | jq -r .hookSpecificOutput.hookEventName)" = SessionStart ]'
check "unknown event falls back to SessionStart" '[ "$(hook_ev Bogus | jq -r .hookSpecificOutput.hookEventName)" = SessionStart ]'
check "english subagent header" 'hook_en SubagentStart | jq -r .hookSpecificOutput.additionalContext | grep -q "subagent"'
# Plain stdout does not reach a subagent's context, so without jq the hook writes the JSON itself.
check "no jq: subagent output is valid JSON" 'HOOK_PATH="$TMP/bin" sub | jq -e .hookSpecificOutput.additionalContext >/dev/null'
check "no jq: subagent JSON equals the jq path" '[ "$(HOOK_PATH="$TMP/bin" subctx)" = "$(subctx)" ]'
check "no jq: subagent has no status line" '[ "$(HOOK_PATH="$TMP/bin" sub | jq -r ".systemMessage // \"none\"")" = none ]'

echo "prompt reminder"
check "prompt: names the top offense" 'upsctx | grep -q "최다 전과: \[개발자 AI법 제17조 제4항\] 테스트 미실행 통과 주장 (재범 2회)"'
check "prompt: reminder <= 200 chars" 'n="$(outchars upsctx)"; [ "$n" -gt 0 ] && [ "$n" -le 200 ]'
check "prompt: no status message" '[ "$(ups | jq -r ".systemMessage // \"none\"")" = none ]'
check "prompt: event name is UserPromptSubmit" '[ "$(ups | jq -r .hookSpecificOutput.hookEventName)" = UserPromptSubmit ]'
check "prompt: exits 0" 'ups >/dev/null'
check "no jq: prompt reminder as plain text" 'HOOK_PATH="$TMP/bin" ups | grep -q "^⚖️ AI 법전 최다 전과"'
rm "$BOOK/enabled-laws" "$BOOK/confessions.md"
check "subagent: nothing to inject, silent" '[ -z "$(sub)" ]'
check "prompt: no ledger, silent, exit 0" '[ -z "$(ups)" ] && ups >/dev/null'
printf '# 반성문 장부\n\n## [A] 횟수 없는 항목\n- 재범: 없음 (최초 2026-10-01)\n\n## [B] 다섯 번 어긴 항목\n- 재범: 5회 (최초 2026-10-01)\n' > "$BOOK/confessions.md"
check "prompt: a repeat line without a count is not read as its date" 'upsctx | grep -qF "[B] 다섯 번 어긴 항목 (재범 5회)"'
rm "$BOOK/confessions.md"

echo "budget"
ls "$KO/skills" > "$BOOK/enabled-laws"
long=""; i=0; while [ "$i" -lt 150 ]; do long="${long}재발방지문장"; i=$((i + 1)); done
{
  printf '# 반성문 장부\n\n'
  i=1
  while [ "$i" -le 12 ]; do
    printf '## [개발자 AI법 제%s조] 예산 항목 %s번\n- 재범: %s회 (최초 2026-10-01)\n- 발생 원인: %s\n- 시정 및 재발 방지: %s\n' \
      "$i" "$i" "$(( (i * 7) % 13 ))" "$long" "$long"
    i=$((i + 1))
  done
  printf '## [개발자 AI법 제99조] 아주 긴 제목 %s\n- 재범: 99회\n' "$long"
} > "$BOOK/confessions.md"
check "budget: SessionStart <= 9000 chars ($(outchars ctx))" '[ "$(outchars ctx)" -le 9000 ]'
check "budget: SubagentStart <= 6000 chars ($(outchars subctx))" '[ "$(outchars subctx)" -le 6000 ]'
check "budget: english SessionStart <= 9000 chars" '[ "$(printf "%s" "$(hook_en | jq -r .hookSpecificOutput.additionalContext)" | nchars)" -le 9000 ]'
check "budget: ledger summary <= 3500 chars" '[ "$(ctx | awk "/^<반성문_장부>/,/^<\/반성문_장부>/" | nchars)" -le 3501 ]'
check "budget: ledger titles present" 'ctx | grep -q "예산 항목 11번"'
check "budget: condensed laws are marked with their full-text path" 'ctx | grep -q "^# 개발자 AI법 (축약)$" && ctx | grep -qF "전문: $KO/skills/developer-ai-law/SKILL.md"'
check "budget: subagent carries the condensed mark too" '[ "$(subctx | grep -c "^# .* (축약)$")" = 14 ] && [ "$(subctx | grep -cF "전문: $KO/skills/")" = 14 ]'
check "budget: english condensed mark" 'hook_en | jq -r .hookSpecificOutput.additionalContext | grep -q "^# .* (condensed)$"'
check "budget: most repeated entry comes first" '[ "$(ctx | lineof "예산 항목 11번")" -lt "$(ctx | lineof "예산 항목 9번")" ]'
check "budget: omitted entries are counted" 'ctx | grep -q "^… 외 [0-9][0-9]*건$"'
check "budget: systemMessage reports condensation" 'msg | grep -q "(축약 주입 [0-9][0-9]*자)"'
check "budget: no broken characters" '! ctx | grep -q "�"'
check "budget: code fences stay balanced" '[ $(( $(ctx | grep -c "^[[:space:]]*\`\`\`") % 2 )) = 0 ]'
check "budget: no jq: plain stdout stays under 10000 chars" '[ "$(HOOK_PATH="$TMP/bin" hook | nchars)" -lt 10000 ]'
check "budget: long ledger lines are cut to 240 chars" '[ "$(ctx | grep "아주 긴 제목" | nchars)" -le 241 ] && ctx | grep -q "아주 긴 제목.*…$"'
check "prompt: long top title still <= 200 chars" 'upsctx | grep -q "아주 긴 제목.*… (재범 99회)" && [ "$(outchars upsctx)" -le 200 ]'
check "prompt: english reminder <= 200 chars" '[ "$(printf "%s" "$(hook_en UserPromptSubmit | jq -r .hookSpecificOutput.additionalContext)" | nchars)" -le 200 ]'
# The harness measures JS string length: an emoji (4-byte UTF-8) is 2 UTF-16 units.
u16() { local s; s="$(cat)"; echo $(( $(printf '%s' "$s" | nchars) + $(printf '%s' "$s" | LC_ALL=C tr -dc '\360-\364' | wc -c) )); }
e="🔥👍🏽"; for i in 1 2 3 4 5 6; do e="$e$e"; done; i=0; while [ "$i" -lt 60 ]; do printf '## [이모지 %s] %s\n- 재범: %s회\n- 시정 및 재발 방지: %s\n' "$i" "$e" "$i" "$e"; i=$((i + 1)); done > "$BOOK/confessions.md"
check "budget: emoji ledger fits in UTF-16 units (9000/6000/200)" '[ "$(ctx | u16)" -le 9000 ] && [ "$(subctx | u16)" -le 6000 ] && [ "$(upsctx | u16)" -le 200 ]'
big="가"; for i in $(seq 18); do big="$big$big"; done; printf '## [긴 줄] %s\n- 재범: 1회\n- 시정 및 재발 방지: %s\n' "$big" "$big" > "$BOOK/confessions.md"
check "budget: a 768KB ledger line is cut fast (< 10s) and within budget" 's=$SECONDS; n="$(ctx | u16)"; [ $((SECONDS - s)) -lt 10 ] && [ "$n" -le 9000 ]'
i=0; while [ "$i" -lt 300 ]; do echo "no-such-law-$i"; i=$((i + 1)); done >> "$BOOK/enabled-laws"
check "budget: 300 unknown laws keep no-jq stdout under 10000 chars" '[ "$(HOOK_PATH="$TMP/bin" hook | nchars)" -lt 10000 ]'
rm "$BOOK/enabled-laws" "$BOOK/confessions.md"

echo "guard"
G="$KO/hooks/guard.sh"
GHOME="$TMP/ghome"
mkdir -p "$GHOME/.claude/ai-lawbook"
guard() { env -i PATH="$PATH" HOME="$GHOME" bash "$G"; }
pre() { jq -n --arg c "$1" --arg d "${2-설명}" '{hook_event_name: "PreToolUse", tool_name: "Bash", tool_input: {command: $c, description: $d}}' | guard; }
decision() { pre "$@" | jq -r '.hookSpecificOutput.permissionDecision // empty'; }
stop() { jq -n --arg e "$1" --arg m "$2" --argjson a "${3:-false}" '{hook_event_name: $e, stop_hook_active: $a, last_assistant_message: $m}' | guard; }
post() { jq -n --arg o "$1" '{hook_event_name: "PostToolUse", tool_name: "Bash", tool_input: {command: "cat x"}, tool_response: {stdout: $o, stderr: "", interrupted: false, isImage: false}}' | guard; }
masked() { post "$1" | jq -r '.hookSpecificOutput.updatedToolOutput.stdout // empty'; }

check "guard: no ledger, silent" '[ -z "$(pre "pkill -f node")" ]'
printf '# 반성문 장부\n\n## [개발자 AI법 제4조] 규칙 없는 항목\n- 재범: 1회\n' > "$GHOME/.claude/ai-lawbook/confessions.md"
check "guard: no rule lines, silent even on broken input" '[ -z "$(printf "not json" | guard)" ] && printf "not json" | guard'
cat > "$GHOME/.claude/ai-lawbook/confessions.md" <<'EOF'
# 반성문 장부

## [개발자 AI법 제5조 제4항] 이름 패턴으로 프로세스 종료
- 재범: 3회
- 시정 및 재발 방지: ps 로 PID 를 확인한 뒤 그 PID 만 종료한다.
- 차단: ([unclosed
- 차단: pkill|
- 차단: \bpkill\b
- 차단: (^|[;&|(\n])\s*git(\s+-C\s+\S+)?\s+stash\s+(pop|apply|drop)\b(?![^;&|\n]*stash@)

## [개발자 AI법 제2조 제2항] 영어로 응답
- 재범: 9회
- 검사: 한국어

## [개발자 AI법 제18조 제3항] 비밀값 노출
- 재범: 2회
- 검사: 비밀값
EOF
check "guard: block rule hit → deny" '[ "$(decision "pkill -f node")" = deny ]'
check "guard: deny reason names the entry and the fix" 'pre "pkill -f node" | jq -r .hookSpecificOutput.permissionDecisionReason | grep -q "「\[개발자 AI법 제5조 제4항\] 이름 패턴으로 프로세스 종료」.*ps 로 PID"'
Q_CMD='echo "pkill is banned" && grep '"'"'pkill'"'"' notes.txt'
check "guard: rule text inside quotes passes" '[ -z "$(pre "$Q_CMD")" ]'
check "guard: invalid or empty-matching regex ignored, other rules still apply" '[ -z "$(pre "ls -la")" ] && [ "$(decision "sudo pkill x")" = deny ]'
ESC_CMD="echo it\\'s; pkill -f node; echo 'done'"; check "guard: an escaped quote does not hide the command after it" '[ "$(decision "$ESC_CMD")" = deny ]'
check "guard: quoted stash@{n} meets the rule's exception" '[ -z "$(pre "git stash drop \"stash@{1}\"")" ] && [ "$(decision "git stash drop")" = deny ]'
check "guard: english Bash description → deny" '[ "$(decision "ls" "List files")" = deny ]'
check "guard: korean Bash description passes" '[ -z "$(pre "ls" "파일 목록 보기")" ]'
check "guard: empty Bash description passes" '[ -z "$(pre "ls" "")" ]'
EN_MSG="I have finished the refactoring, and every test in the suite passes now."
check "guard: english final answer → block" '[ "$(stop Stop "$EN_MSG" | jq -r .decision)" = block ]'
check "guard: english subagent answer → block" '[ "$(stop SubagentStop "$EN_MSG" | jq -r .decision)" = block ]'
check "guard: stop_hook_active passes" '[ -z "$(stop Stop "$EN_MSG" true)" ]'
KO_MSG="$(printf '리팩터링을 마쳤다. `npm run test --workspaces` 결과:\n```\nPASS src/components/Button.test.tsx (all suites passed successfully)\n```')"
check "guard: korean answer with code blocks passes" '[ -z "$(stop Stop "$KO_MSG")" ]'
CODE_KO_MSG="$(printf 'Done. I updated the module and here is the summary of the change.\n```\n# 한국어 주석\n```')"
check "guard: korean only inside code blocks does not count" '[ "$(stop Stop "$CODE_KO_MSG" | jq -r .decision)" = block ]'
check "guard: broken input → silent, exit 0" '[ -z "$(printf "not json" | guard)" ] && printf "not json" | guard'
LONG_EN="$(printf 'word %.0s' $(seq 20000))"  # jq 1.7 global matching is quadratic: this once took 16s
check "guard: a 100K-char answer is judged within 5s" 's=$SECONDS; [ "$(stop Stop "$LONG_EN" | jq -r .decision)" = block ] && [ $((SECONDS - s)) -lt 5 ]'

YAML="$(printf 'spring:\n  datasource:\n    url: jdbc:postgresql://db:5432/app\n    password: s3cr3tYamlValue')"
check "guard: masks YAML password" 'out="$(masked "$YAML")"; printf "%s" "$out" | grep -q "password: <가림>" && ! printf "%s" "$out" | grep -q s3cr3tYamlValue'
check "guard: masks .env keys" 'out="$(masked "DB_PASSWORD=envSecret1 API_KEY=\"quoted secret\"")"; ! printf "%s" "$out" | grep -qE "envSecret1|quoted secret" && printf "%s" "$out" | grep -q "DB_PASSWORD=<가림>"'
check "guard: masks DSN credentials" '[ "$(masked "postgresql://admin:Pa55word@db.local:5432/app")" = "postgresql://admin:<가림>@db.local:5432/app" ]'
check "guard: masks Bearer tokens" '[ "$(masked "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.payload")" = "Authorization: Bearer <가림>" ]'
check "guard: masks sk- keys" '! masked "key is sk-proj-abcdef123456" | grep -q abcdef123456'
check "guard: keeps code like const token = getToken();" '[ -z "$(post "const token = getToken();")" ]'
MORE="$(printf '  "apiKey": "k1"\n  DB_PASSWORD: k2\n{"password":"k3"}\n-----BEGIN PRIVATE KEY-----\nk4\n-----END PRIVATE KEY-----\nredis://:k5@cache:6379')"
check "guard: masks camelCase/uppercase keys, one-line JSON, PEM bodies, empty-user DSN" 'out="$(masked "$MORE")"; [ -n "$out" ] && ! printf "%s" "$out" | grep -qE "k[1-5]"'
check "guard: keeps code calls, plural keys and look-alikes" '[ -z "$(post "$(printf "token = get_token()\nmax_tokens: 4096\ntask-runner-config.yml\nhttp://localhost:5173/@vite/client")")" ]'
check "guard: masks secrets but keeps code in the same output" '[ "$(masked "$(printf "const token = getToken();\npassword=hunter22")")" = "$(printf "const token = getToken();\npassword=<가림>")" ]'
check "guard: no secrets, silent" '[ -z "$(post "total 0
drwxr-xr-x  2 user  staff  64 Oct 25 src")" ]'
check "guard: output keeps the tool output shape" '[ "$(post "password: x1" | jq -c ".hookSpecificOutput | [.hookEventName, (.updatedToolOutput | keys)]")" = "[\"PostToolUse\",[\"interrupted\",\"isImage\",\"stderr\",\"stdout\"]]" ]'
# A shape that differs from the tool's output is ignored by the harness, which would let the raw secret through.
NO_STDERR='{hook_event_name: "PostToolUse", tool_name: "Bash", tool_response: {stdout: "password: x1", interrupted: false, isImage: false}}'
check "guard: masking adds no missing keys" '[ "$(jq -n "$NO_STDERR" | guard | jq -c ".hookSpecificOutput.updatedToolOutput | keys")" = "[\"interrupted\",\"isImage\",\"stdout\"]" ]'

echo "laws"
ko_names="$(cd "$KO/skills" && ls -d */ 2>/dev/null | tr -d / | sort)"
en_names="$(cd "$EN/skills" && ls -d */ 2>/dev/null | tr -d / | sort)"
check "14 skills in the Korean plugin" '[ "$(printf "%s\n" "$ko_names" | grep -c .)" = 14 ]'
check "ko and en ship the same skills" '[ "$ko_names" = "$en_names" ]'

for name in $ko_names; do
  for side in "$KO" "$EN"; do
    f="$side/skills/$name/SKILL.md"
    tag="$([ "$side" = "$KO" ] && echo ko || echo en)/$name"
    [ -r "$f" ] || { fail "$tag: SKILL.md missing"; continue; }
    fm_name="$(awk 'NR>1 && /^---$/ {exit} /^name:/ {sub(/^name: */, ""); print}' "$f")"
    desc="$(awk 'NR>1 && /^---$/ {exit} /^description:/ {sub(/^description: */, ""); print}' "$f")"
    check "$tag: frontmatter name matches directory" '[ "$fm_name" = "$name" ]'
    # Count UTF-8 characters, not bytes, whatever the locale: drop continuation bytes (0x80-0xBF).
    chars="$(printf "%s" "$desc" | LC_ALL=C tr -d '\200-\277' | wc -c | tr -d ' ')"
    check "$tag: description present, <= 1024 chars ($chars)" '[ -n "$desc" ] && [ "$chars" -le 1024 ]'
    check "$tag: agents/openai.yaml present" '[ -r "$side/skills/$name/agents/openai.yaml" ]'
    [ "$name" = ai-lawmaker ] && continue
    check "$tag: references the confession ledger" 'grep -q "~/.claude/ai-lawbook/confessions.md" "$f"'
    if [ "$side" = "$KO" ]; then
      check "$tag: completion verdict line" 'grep -q "판결: 무혐의 — 관련 검증 완료" "$f"'
      check "$tag: AI death penalty" 'grep -q "AI 사형" "$f"'
    else
      check "$tag: completion verdict line" 'grep -q "Verdict: Not guilty — relevant checks passed" "$f"'
      check "$tag: AI death penalty" 'grep -q "AI Death Penalty" "$f"'
    fi
  done
  ko_n="$(grep -c '^### ' "$KO/skills/$name/SKILL.md" 2>/dev/null)"
  en_n="$(grep -c '^### ' "$EN/skills/$name/SKILL.md" 2>/dev/null)"
  check "$name: ko/en article count match ($ko_n/$en_n)" '[ "$ko_n" = "$en_n" ]'
done

echo
if [ "$fails" -eq 0 ]; then echo "all checks passed"; else echo "$fails check(s) failed"; exit 1; fi
