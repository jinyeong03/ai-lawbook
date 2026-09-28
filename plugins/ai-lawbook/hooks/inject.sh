#!/usr/bin/env bash
#
# ai-lawbook SessionStart·SubagentStart hook — 시행 명부의 법 본문과 반성문 장부를 주입한다.
#
# 왜 훅인가: "먼저 ○○ 스킬을 호출하라"는 지시는 모델이 건너뛸 수 있지만, 훅은 하네스가
# 실행하므로 건너뛸 수 없다. 그래서 스킬 호출을 부탁하는 대신 조문을 컨텍스트에 직접 넣는다.
#
# 사용법: inject.sh [ko|en] [SessionStart|SubagentStart]   (hooks.json 이 언어와 이벤트를 넘긴다)
#
# 왜 SubagentStart 도인가: SessionStart 로 넣은 컨텍스트는 하위 에이전트(서브에이전트·워크플로
# 에이전트)에 전달되지 않는다. 그래서 하위 에이전트는 법도 전과도 모른 채 첫 호출을 한다. 장부의
# 재발 방지책은 장부를 읽은 뒤에야 보이므로, 하위 에이전트가 시작할 때 같은 내용을 다시 넣는다.
# 하위 에이전트마다 사용자 화면에 상태 메시지를 띄우면 소음이 되므로 SubagentStart 는 조용히 넣는다.
#
#   ~/.claude/ai-lawbook/enabled-laws   한 줄에 법 이름 하나, # 뒤는 주석
#   ~/.claude/ai-lawbook/confessions.md 반성문 장부 (있으면 항상 주입)
#
# 법 파일 조회 순서: 프로젝트 .claude/skills → ~/.claude/skills → 플러그인 내장.
# 사용자가 제정·개정한 법이 내장 법보다 우선한다.
#
# 실패 정책: 파일이 없거나 못 읽으면 조용히 넘어간다(exit 0). 세션 시작을 막는 것이
# 법을 한 번 못 읽는 것보다 나쁘다.
set -uo pipefail

LANG_CODE="${1:-ko}"
EVENT="${2:-SessionStart}"
case "$EVENT" in SessionStart|SubagentStart) ;; *) EVENT=SessionStart ;; esac
BOOK="${HOME}/.claude/ai-lawbook"
ROSTER="${BOOK}/enabled-laws"
LEDGER="${BOOK}/confessions.md"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

SEARCH_DIRS=()
[ -n "${CLAUDE_PROJECT_DIR:-}" ] && SEARCH_DIRS+=("${CLAUDE_PROJECT_DIR}/.claude/skills")
SEARCH_DIRS+=("${HOME}/.claude/skills" "${PLUGIN_ROOT}/skills")

# YAML 프론트매터 제거. description 은 스킬 트리거 조건이지 조문이 아니다.
strip_frontmatter() {
  awk '
    skip == 0 && NR == 1 && $0 == "---" { skip = 1; next }
    skip == 1 && $0 == "---"            { skip = 2; next }
    skip != 1                           { print }
  ' "$1"
}

find_law() {
  local dir
  for dir in "${SEARCH_DIRS[@]}"; do
    if [ -r "${dir}/$1/SKILL.md" ]; then
      printf '%s' "${dir}/$1/SKILL.md"
      return 0
    fi
  done
  return 1
}

laws=""
enabled=()
missing=()
if [ -r "$ROSTER" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    name="${line%%#*}"
    name="$(printf '%s' "$name" | tr -d '[:space:]')"
    [ -n "$name" ] || continue
    # 이름은 kebab-case 만 허용한다. `../` 같은 경로가 명부를 통해 들어오지 못하게 한다.
    if ! [[ "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
      missing+=("$name")
      continue
    fi
    case " ${enabled[*]-} " in *" ${name} "*) continue ;; esac
    if file="$(find_law "$name")"; then
      body="$(strip_frontmatter "$file")"
      [ -n "$body" ] || continue
      enabled+=("$name")
      laws="${laws}${laws:+$'\n\n---\n\n'}${body}"
    else
      missing+=("$name")
    fi
  done < "$ROSTER"
fi

ledger=""
entries=0
if [ -r "$LEDGER" ]; then
  ledger="$(cat "$LEDGER")"
  entries="$(grep -c '^## \[' "$LEDGER" || true)"
fi

[ -n "$laws" ] || [ -n "$ledger" ] || [ "${#missing[@]}" -gt 0 ] || exit 0

if [ "$LANG_CODE" = "en" ]; then
  LAWS_HEAD='<ai-lawbook>
The AI Laws below are **already in force** for this session: the user listed them in the
enforcement roster (~/.claude/ai-lawbook/enabled-laws). Do not decide whether they apply.
- Use them as the quality gate for every task in their roles, however small the task looks.
- Do not load these laws again with the `Skill` tool; their full text is already here
  (unless the user types the slash command themselves).
- When you finish substantive work, end with the one-line Completion Verdict of the relevant law.'
  SUB_NOTE='- This holds when you run as a subagent (subagent or workflow agent) too: the SubagentStart hook
  put this block here, so apply the laws from your very first tool call.'
  LEDGER_HEAD='<confession-ledger>
Confessions the AI recorded about its own violations in past sessions. Check the entries related
to the current task before you start. Repeating a recorded violation is an aggravated violation.'
  LEDGER_TAIL='</confession-ledger>'
  MSG="AI Lawbook: ${#enabled[@]} law(s) in force, ${entries} confession(s) on record"
  MISS_MSG="not found in the lawbook, skipped"
else
  LAWS_HEAD='<ai-lawbook>
아래 AI법은 사용자가 시행 명부(~/.claude/ai-lawbook/enabled-laws)에 올려 이 세션에
**이미 적용되어 있다.** 적용 여부를 판단하지 말라.
- 해당 직무의 모든 작업에서 조문을 품질 게이트로 쓴다. 작업이 작아 보여도 생략하지 않는다.
- 여기 주입된 법은 `Skill` 도구로 다시 호출하지 않는다. 본문이 이미 여기 있다.
  (사용자가 슬래시 명령을 직접 입력한 경우는 예외)
- 실질적인 작업을 마치면 해당 법의 완료 판결 한 줄을 남긴다.'
  SUB_NOTE='- 하위 에이전트(서브에이전트·워크플로 에이전트)로 실행 중이어도 같다. 이 블록은 SubagentStart
  훅이 넣었으니 첫 도구 호출부터 조문을 적용한다.'
  LEDGER_HEAD='<반성문_장부>
과거 세션에서 AI가 법을 어기고 스스로 기록한 반성문이다. 작업 전에 관련 항목을 점검하라.
기록된 위반을 다시 범하면 가중 위반이다.'
  LEDGER_TAIL='</반성문_장부>'
  MSG="AI 법전: 시행 중 ${#enabled[@]}개, 반성문 ${entries}건"
  MISS_MSG="법전에 없어 건너뜀"
fi

[ "${#enabled[@]}" -gt 0 ] && MSG="${MSG} (${enabled[*]})"
[ "${#missing[@]}" -gt 0 ] && MSG="${MSG} — ${missing[*]}: ${MISS_MSG}"

[ "$EVENT" = SubagentStart ] && LAWS_HEAD="${LAWS_HEAD}"$'\n'"${SUB_NOTE}"
LAWS_HEAD="${LAWS_HEAD}"$'\n''</ai-lawbook>'

payload=""
[ -n "$laws" ] && payload="${LAWS_HEAD}"$'\n\n'"${laws}"
[ -n "$ledger" ] && payload="${payload}${payload:+$'\n\n'}${LEDGER_HEAD}"$'\n\n'"${ledger}"$'\n'"${LEDGER_TAIL}"

# jq 가 있으면 문서화된 경로(hookSpecificOutput.additionalContext)로 넣는다.
# 없으면 표준출력으로 떨어뜨린다. SessionStart·SubagentStart 는 표준출력도 컨텍스트에 넣는다.
if [ "$EVENT" = SubagentStart ]; then
  [ -n "$payload" ] || exit 0
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$payload" | jq -Rs '{ hookSpecificOutput: { hookEventName: "SubagentStart", additionalContext: . } }'
  else
    printf '%s\n' "$payload"
  fi
elif command -v jq >/dev/null 2>&1; then
  printf '%s' "$payload" | jq -Rs --arg msg "$MSG" '{
    systemMessage: $msg,
    suppressOutput: true,
    hookSpecificOutput: { hookEventName: "SessionStart", additionalContext: . }
  }'
else
  printf '%s\n\n%s\n' "$MSG" "$payload"
fi
