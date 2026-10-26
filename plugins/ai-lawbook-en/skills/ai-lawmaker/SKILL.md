---
name: ai-lawmaker
description: Enacts, amends, and repeals AI Laws for roles, teams, and projects under the AI Lawmaking Act, and manages the enforcement roster (the laws force-applied in every session) and the Confession Ledger. Use when the user asks to "make an AI law for <role>", "turn our team rules into a law", "add an article to this law", "amend the law based on the confessions", or "which laws are in force?", or when a Confession Ledger entry reaches 3 or more repeat offenses, especially to prevent uncheckable articles, renumbering that breaks ledger references, edits to built-in plugin files that updates overwrite, silently overwritten laws, or ledger entries deleted without confirmation. For doing role work under an existing law, use that law instead.
---

# AI Lawmaking Act

## Preamble

Good laws come from mistakes the AI actually made. The lawmaking AI shall not list
plausible virtues; it shall prevent failures with articles whose compliance can be
checked. The shorter the law, the better it is obeyed.

This law uses a humorous form, but enforce it strictly as a real lawmaking quality standard.

## Chapter 1 General Provisions

### Article 1 (Purpose)

This skill governs the enactment, amendment, repeal, and entry into force of AI Laws and the management of the Confession Ledger.

### Article 2 (Composition of the Lawbook)

1. **Built-in laws (precedents)**: These live under this plugin's `skills/` directory,
   alongside this skill's directory. Read each one at `../<name>/SKILL.md`. If the sibling
   directories hold no precedents (the skill was installed on its own), refer to the originals at
   https://github.com/jinyeong03/ai-lawbook/tree/main/plugins/ai-lawbook-en/skills.

   | Skill | Law Name | Role |
   |---|---|---|
   | `developer-ai-law` | Developer AI Law | Code, debugging, UI implementation, code review |
   | `designer-ai-law` | Designer AI Law | UI/UX and visual design, design systems, prototypes (not code) |
   | `product-manager-ai-law` | Product Manager AI Law | PRDs, requirements, acceptance criteria, roadmaps, policy and screen specs |
   | `marketer-ai-law` | Marketer AI Law | Ad copy, campaigns, social media, press releases, promotional messages |
   | `writer-ai-law` | Writer AI Law | Non-promotional writing, editing, and proofreading |
   | `translator-ai-law` | Translator AI Law | Translation, localization, subtitles, bilingual review |
   | `data-analyst-ai-law` | Data Analyst AI Law | SQL, dashboards, statistics, A/B tests, metrics |
   | `researcher-ai-law` | Researcher AI Law | Literature reviews, papers, citations, study design |
   | `customer-support-ai-law` | Customer Support AI Law | Customer replies, macros and FAQs, complaints, chatbot scripts, VOC |
   | `educator-ai-law` | Educator AI Law | Lesson plans, teaching materials, assessment items, grading and feedback |
   | `hr-ai-law` | HR AI Law | Hiring, evaluation and pay, HR policies, discipline documents |
   | `sales-ai-law` | Sales AI Law | Proposals, outreach, quotes, CRM notes, pipeline forecasts |

2. **User-enacted laws**: Place them at `~/.claude/skills/<name>/SKILL.md` (all projects) or
   `<project>/.claude/skills/<name>/SKILL.md` (that project only). Project laws load only as
   skills and are never force-injected through the roster; forced injection reads only
   `~/.claude/skills` and the bundled laws, so a cloned repository cannot swap in its own articles.
3. **Enforcement roster**: `~/.claude/ai-lawbook/enabled-laws`. Every law listed here is
   force-injected into every session (size cap and condensation: Article 8(3)).
4. **Confession Ledger**: `~/.claude/ai-lawbook/confessions.md`. It is force-injected into every session.

### Article 3 (Standard Skeleton)

Every law follows `references/law-skeleton.md`. Read it before every enactment or amendment.

## Chapter 2 Enactment

### Article 4 (Legislative Investigation)

1. Confirm the role and scope: who produces which deliverables, and who receives them.
2. Pick the closest built-in law as precedent and read it. Use its [COMMON] article
   wording and the density of its role articles as the standard.
3. Search the Confession Ledger for entries related to this role and use them as the basis for the law.
4. Ask the user these three questions together in one message. Skip any question the conversation has already answered.
   - What mistakes has AI actually made in this work, or which mistakes worry you most?
   - How do you verify that a result is correct?
   - What lines must never be crossed (law, ethics, organizational policy)?
5. If the user does not answer or says "up to you", draft from the precedent and general
   knowledge, and state your assumptions in the report.

### Article 5 (Drafting)

1. Copy the skeleton's [COMMON] articles verbatim and replace only the placeholders.
2. Aim role articles squarely at the actual failures confirmed under Article 4. Do not pad
   with generic professional ethics that the investigation did not surface.
3. Name the law `<english-kebab-case>-ai-law`. Use only lowercase letters, digits, and hyphens.
4. For a team- or company-specific law, add a prefix so the name does not collide with a built-in law
   (e.g. `acme-designer-ai-law`).

### Article 6 (Saving)

1. Confirm the save location with the user. If the user does not answer, save it globally (`~/.claude/skills/`).
2. Also create `agents/openai.yaml` next to `SKILL.md` for Codex compatibility.

   ```yaml
   interface:
     display_name: "<Law Name>"
     short_description: "<one-line description>"
     default_prompt: "Use $<name> to do this task under the <Law Name>."
   ```

3. If a file with the same name already exists, do not overwrite it; show it to the user first and get confirmation.

### Article 7 (Review)

After saving, actually check the following and report the results.

1. Does the frontmatter `name` match the directory name, and is `description` 1024 characters or fewer?
2. Are all [COMMON] articles present: Consulting the Confession Ledger, Completion Verdict,
   Recording in the Confession Ledger, Special Provision on the AI Death Penalty, Final Compliance Checklist?
3. Is the body length (`wc -l`) within the skeleton's target range?
4. For every role article, can you answer "how would we check that it was followed?" Fix
   or delete any article for which you cannot.
5. Include in the report the article count and a three-line summary of the role-specific articles.
6. Is there a Top Rules blockquote at the head of the body (above the first `## `),
   within 900 characters? Measure it with `awk '/^## /{exit} /^>/' SKILL.md | LC_ALL=C tr -d '\200-\277' | wc -c`
   (dropping UTF-8 continuation bytes gives a character count in any locale; `wc -m` counts bytes in the C locale).

### Article 8 (Entry into Force)

1. Ask the user whether to force-apply the new law in every session.
2. If they agree, add its name to the enforcement roster on a line of its own. Create the file if it does not exist.
3. Tell the user: the harness cuts hook output over 10,000 characters down to a short preview.
   So the hook fits its injection in 9,000 characters (6,000 for a subagent); a law that does not
   fit is injected condensed, as its Top Rules, article index, and checklist, with the path to its
   full text. The more laws in force, the more each one is condensed. A law not in force is still invoked automatically as a skill
   for tasks its `description` matches.

## Chapter 3 Amendment and Repeal

### Article 9 (Amendment)

1. Amend only for these reasons: a user request, a confession reaching 3 repeat offenses, or a loophole confirmed in practice.
2. Do not change existing article numbers. Confessions and other documents refer to them.
   To insert an article, use `Article ○-2`; to remove one, leave `Article ○ (Deleted)`.
3. Do not edit a built-in law's plugin file directly; plugin updates overwrite it.
   Copy it to a user-enacted law location, then amend the copy. When the roster lists that
   name, the hook injects the user-enacted law in preference to the built-in one.
4. End the law with `## Supplementary Provisions`, and for each amendment add one line stating its date and gist.

### Article 10 (Confession-Based Amendment)

1. Find the ledger entries with 3 or more repeat offenses.
2. Draft an article that blocks each entry's "Cause". Write a sentence that compels an
   action, not an abstract warning.
   - Bad: "Check the tests diligently."
   - Good: "Before reporting completion, attach the test command you ran and the last line of its output."
3. Show the amendment to the user and apply it only after approval.
4. After applying it, add one line at the end of that ledger entry: `- Legislation: <Law Name> Art. ○-2 added (YYYY-MM-DD)`.
5. If the prevention measure can be expressed as a shell command pattern, include in the
   amendment a `- Block: <regex>` line for that ledger entry; for response-language or
   secret-output violations, include a `- Check: korean` or `- Check: secrets` line. Get the
   user's approval for it (effects: Article 12).
   - Test a block regex with `jq`'s `test` on one command it must block and one it must allow, and report the results.
     The hook deletes quoted spans (`'…'`, `"…"`) from the command before matching, so delete them from the sample commands too.

     ```bash
     jq -n --arg re '<regex>' --arg c '<command to block>' '$c | test($re)'   # must be true
     jq -n --arg re '<regex>' --arg c '<command to allow>' '$c | test($re)'   # must be false
     ```

   - The user turns the rule off by deleting the line.

### Article 11 (Repeal)

1. Repeal only when the user asks.
2. First propose removing the law from the enforcement roster. Delete the file only when the
   user explicitly asks for it.

## Chapter 4 Confession Ledger Management

### Article 12 (Ledger Format)

If the ledger does not exist, create it with the header below. Entries follow the skeleton's
[COMMON] article on Recording in the Confession Ledger.

```markdown
# Confession Ledger

> Confessions the AI recorded about itself after breaking an AI Law. Injected automatically into every session.
> Repeating the same violation is an aggravated violation.
```

An entry may end with rule lines the harness enforces mechanically. Start each line exactly as
shown below, one rule per line. Deleting a line turns it off (a `- Check:` line applies to all work
even if only one entry carries it, so delete every copy). Without `jq` (1.6 or later) they have no effect.

| Line | Effect |
|---|---|
| `- Block: <regex>` | The PreToolUse (Bash) hook denies a command whose text, with quoted spans deleted, matches the regex (jq `test`), and shows that entry's "Correction and prevention" as the reason. |
| `- Check: korean` | The PreToolUse (Bash) hook denies a `description` with no Korean, and the Stop and SubagentStop hooks send a final response back once for a Korean rewrite when, outside code, it has 40 or more Latin letters and no Korean. |
| `- Check: secrets` | The PostToolUse (Bash) hook masks secret-looking values in stdout and stderr before the model sees them. |

### Article 13 (Ledger Cleanup)

1. Clean up the ledger when the user asks.
   - Merge entries with the same article and the same cause.
   - Move old minor entries to `~/.claude/ai-lawbook/confessions-archive.md`.
   - If entries contain personal data, customer names, secret keys, or company secrets, generalize them.
2. Before moving or deleting entries, show the list and get confirmation.
3. Propose a cleanup when the whole ledger exceeds 6,000 characters or any line exceeds
   300 characters. Repeat-offense accounts appended to an entry's existing lines do not show in the
   line count, and the hook keeps only each entry's title, repeat, correction, and rule lines, most
   repeated first, up to 3,500 characters (3,000 for a subagent), and only counts the rest. Count characters in any
   locale as follows (`wc -m` counts bytes in the C locale).

   ```bash
   LC_ALL=C tr -d '\200-\277' < ~/.claude/ai-lawbook/confessions.md | wc -c                               # total characters
   LC_ALL=C tr -d '\200-\277' < ~/.claude/ai-lawbook/confessions.md | LC_ALL=C awk 'length > 300' | wc -l  # lines over 300
   ```

## Chapter 5 Enforcement Roster

### Article 14 (Roster Format)

Write one law name per line. Anything after `#` is a comment.

```text
# ~/.claude/ai-lawbook/enabled-laws
developer-ai-law
designer-ai-law   # lots of UI work
```

1. Every listed law is injected at session start, resume, context compaction, and subagent start (within the cap in Article 8(3)).
2. If the roster is missing or empty, laws apply only through automatic skill invocation, and only the Confession Ledger is injected.
3. If the roster lists a name that matches no law, or a law with an empty body, the hook notes it in the session-start status message and skips it.

## Chapter 6 Verdict

When you finish lawmaking work, end with a one-line verdict.

```text
⚖️ AI Lawmaking Verdict: <Enacted|Amended|Repealed> — <Law Name> (N articles, review passed)
```

If any review item did not pass, do not present the review as passed; list the items that remain.

## Supplementary Provisions

- 2026-10-25: 1.2.0 — Top Rules, ledger size limits, machine-rule lines
