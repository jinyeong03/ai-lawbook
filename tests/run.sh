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

# Runs the hook with an isolated HOME. Extra env assignments may be passed as args.
hook() { env -i PATH="${HOOK_PATH:-$PATH}" HOME="$TMP/home" CLAUDE_PLUGIN_ROOT="$KO" "$@" bash "$KO/hooks/inject.sh" ko; }
ctx() { hook "$@" | jq -r '.hookSpecificOutput.additionalContext'; }
msg() { hook "$@" | jq -r '.systemMessage'; }

echo "manifests"
for f in "$ROOT/.claude-plugin/marketplace.json" "$KO/.claude-plugin/plugin.json" "$EN/.claude-plugin/plugin.json" \
         "$KO/hooks/hooks.json" "$EN/hooks/hooks.json"; do
  check "valid JSON: ${f#$ROOT/}" 'jq empty "$f" 2>/dev/null'
done
check "both plugins ship the identical hook script" 'cmp -s "$KO/hooks/inject.sh" "$EN/hooks/inject.sh"'

echo "hook"
mkdir -p "$TMP/home/.claude/ai-lawbook"
check "no roster, no ledger: silent, exit 0" '[ -z "$(hook)" ] && hook >/dev/null'

printf '# comment\n\ndeveloper-ai-law   # inline comment\ndeveloper-ai-law\nno-such-law\n../../etc\n' \
  > "$TMP/home/.claude/ai-lawbook/enabled-laws"
check "roster: injects law body" 'ctx | grep -q "^# 개발자 AI법"'
check "roster: strips frontmatter" '! ctx | grep -q "^name: developer-ai-law"'
check "roster: duplicate name injected once" '[ "$(ctx | grep -c "^# 개발자 AI법")" = 1 ]'
check "roster: unknown law reported" 'msg | grep -q "no-such-law"'
check "roster: path traversal rejected" 'msg | grep -q "\.\./\.\./etc" && ! ctx | grep -q "root:"'
check "systemMessage counts laws" 'msg | grep -q "시행 중 1개"'

mkdir -p "$TMP/home/.claude/skills/developer-ai-law"
printf -- '---\nname: developer-ai-law\ndescription: x\n---\n# USER OVERRIDE LAW\n' \
  > "$TMP/home/.claude/skills/developer-ai-law/SKILL.md"
check "user-enacted law overrides the built-in one" 'ctx | grep -q "USER OVERRIDE LAW" && ! ctx | grep -q "^# 개발자 AI법"'
mkdir -p "$TMP/proj/.claude/skills/developer-ai-law"
printf '# PROJECT LAW\n' > "$TMP/proj/.claude/skills/developer-ai-law/SKILL.md"
check "project law overrides the user law" 'ctx CLAUDE_PROJECT_DIR="$TMP/proj" | grep -q "PROJECT LAW"'
rm -rf "$TMP/home/.claude/skills" "$TMP/proj"

printf '# 반성문 장부\n\n## [개발자 AI법 제17조 제4항] 테스트 미실행 통과 주장\n- 재범: 2회\n' \
  > "$TMP/home/.claude/ai-lawbook/confessions.md"
check "ledger injected" 'ctx | grep -q "테스트 미실행 통과 주장"'
check "ledger entries counted" 'msg | grep -q "반성문 1건"'
rm "$TMP/home/.claude/ai-lawbook/enabled-laws"
check "ledger alone (no roster) still injected" 'ctx | grep -q "<반성문_장부>" && ! ctx | grep -q "<ai-lawbook>"'

check "english header" 'env -i PATH="$PATH" HOME="$TMP/home" CLAUDE_PLUGIN_ROOT="$EN" bash "$EN/hooks/inject.sh" en | jq -r .hookSpecificOutput.additionalContext | grep -q "<confession-ledger>"'

# Without jq the hook must fall back to plain stdout instead of going silent.
mkdir -p "$TMP/bin"
for t in bash awk grep tr cat dirname; do ln -sf "$(command -v "$t")" "$TMP/bin/$t"; done
check "no jq: plain-text fallback" 'HOOK_PATH="$TMP/bin" hook | grep -q "테스트 미실행 통과 주장"'

# SessionStart context does not reach subagents, so the same payload is injected again on SubagentStart.
echo "subagents"
hook_ev() { local ev="$1"; shift; env -i PATH="${HOOK_PATH:-$PATH}" HOME="$TMP/home" CLAUDE_PLUGIN_ROOT="$KO" "$@" bash "$KO/hooks/inject.sh" ko "$ev"; }
sub() { hook_ev SubagentStart "$@"; }
subctx() { sub "$@" | jq -r '.hookSpecificOutput.additionalContext'; }
sub_cmd() { jq -r '.hooks.SubagentStart[0].hooks[0].command // empty' "$1"; }
SUB_KO='/hooks/inject.sh" ko SubagentStart'
SUB_EN='/hooks/inject.sh" en SubagentStart'
check "SubagentStart hook registered (ko)" 'sub_cmd "$KO/hooks/hooks.json" | grep -qF "$SUB_KO"'
check "SubagentStart hook registered (en)" 'sub_cmd "$EN/hooks/hooks.json" | grep -qF "$SUB_EN"'
printf 'developer-ai-law\n' > "$TMP/home/.claude/ai-lawbook/enabled-laws"
check "subagent: event name is SubagentStart" '[ "$(sub | jq -r .hookSpecificOutput.hookEventName)" = SubagentStart ]'
check "subagent: law body injected" 'subctx | grep -q "^# 개발자 AI법"'
check "subagent: ledger injected" 'subctx | grep -q "테스트 미실행 통과 주장"'
check "subagent: header says the laws bind subagents" 'subctx | grep -q "하위 에이전트"'
check "subagent: no status message per spawn" '[ "$(sub | jq -r ".systemMessage // \"none\"")" = none ]'
check "session: header has no subagent note" '! ctx | grep -q "하위 에이전트"'
check "session: event name stays SessionStart" '[ "$(hook | jq -r .hookSpecificOutput.hookEventName)" = SessionStart ]'
check "unknown event falls back to SessionStart" '[ "$(hook_ev Bogus | jq -r .hookSpecificOutput.hookEventName)" = SessionStart ]'
check "english subagent header" 'env -i PATH="$PATH" HOME="$TMP/home" CLAUDE_PLUGIN_ROOT="$EN" bash "$EN/hooks/inject.sh" en SubagentStart | jq -r .hookSpecificOutput.additionalContext | grep -q "subagent"'
check "no jq: subagent plain-text fallback without status line" 'out="$(HOOK_PATH="$TMP/bin" sub)"; printf "%s" "$out" | grep -q "테스트 미실행 통과 주장" && ! printf "%s" "$out" | grep -q "^AI 법전:"'
rm "$TMP/home/.claude/ai-lawbook/enabled-laws" "$TMP/home/.claude/ai-lawbook/confessions.md"
check "subagent: nothing to inject, silent" '[ -z "$(sub)" ]'

echo "laws"
ko_names="$(cd "$KO/skills" && ls -d */ 2>/dev/null | tr -d / | sort)"
en_names="$(cd "$EN/skills" && ls -d */ 2>/dev/null | tr -d / | sort)"
check "13 skills in the Korean plugin" '[ "$(printf "%s\n" "$ko_names" | grep -c .)" = 13 ]'
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
