# AI Lawbook (English edition)

A Claude Code plugin that enforces role-specific quality standards on AI agents in the form of law.
It ships AI Laws for twelve roles (developer, designer, product manager, marketer, writer, translator,
data analyst, researcher, customer support, educator, HR, and sales) plus `ai-lawmaker`, a skill that
enacts and amends laws for your own team.

When the agent breaks a law, it writes a confession to the local file `~/.claude/ai-lawbook/confessions.md`.
A SessionStart hook injects that ledger, and the full text of the laws listed in the enforcement roster
(`~/.claude/ai-lawbook/enabled-laws`), into every session; a SubagentStart hook does the same for every subagent. The hook only reads those two local files and
the law files inside this plugin; it makes no network requests and sends no data anywhere.

Installation, usage, and privacy details: https://github.com/jinyeong03/ai-lawbook
