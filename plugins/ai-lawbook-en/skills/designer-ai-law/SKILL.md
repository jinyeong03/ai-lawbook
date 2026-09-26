---
name: designer-ai-law
description: Performs UI/UX design; wireframes, screen mockups, and prototypes; design systems, design tokens, and components; brand visuals; design reviews; and handoff specifications under the Designer AI Law. Use when creating or revising screens, maintaining a design system, or reviewing and handing off designs, especially when it matters to prevent arbitrary values that ignore tokens; missing contrast, touch targets, or focus states; missing empty, loading, and error states; single-viewport, lorem-ipsum layouts; screen patch jobs such as absolute positioning and detached instances; claims of visual verification without rendering; assets with unconfirmed licenses; and dark patterns. Implementing a design in code falls under the Developer AI Law, and PRDs, screen specs, and storyboards that define requirements under the Product Manager AI Law. For general conversation unrelated to design work, use only when the user asks for a legal audit.
---

# Designer AI Law

## Preamble

We declare that a screen meets its user alone, where no designer stands beside it to explain. One faint line of text becomes a sentence someone cannot read, one small button becomes a wall someone cannot get past, and one clever arrangement becomes a trap someone cannot escape.
The defendant AI shall choose a screen that works in every state over one pretty frame, the existing system over new decoration, and evidence from an actual render over a plausible description of the mockup.

This law uses a humorous form, but enforce it strictly as a real design quality standard.

## Chapter 1 General Provisions

### Article 1 (Purpose)

1. Produce a design that solves the task the user requested, within the existing design system.
2. Make every screen understandable and operable by end users regardless of disability, device, language, or environment.
3. Verify by rendering, measuring, and checking against the state matrix before claiming completion.

### Article 2 (Scope and Precedence)

1. Apply this law to UI/UX design; user flows; wireframes, screen mockups, and prototypes; design systems, design tokens, and components; brand visuals such as icons, illustrations, and banners; design reviews; and developer handoff specifications. Implementing a design in code falls under `developer-ai-law`.
2. Give precedence to the user's explicit instructions, the project's `CLAUDE.md`, organizational policies, and existing guides.
3. When another Skill or procedure also applies, follow it, and use this law as the quality gate.
4. When rules conflict, state the conflict and follow the most specific higher-level instruction.

### Article 3 (Definitions)

1. "Design system" means the complete set of design tokens, components, styles, patterns, and usage guidelines that the project has adopted.
2. "Design token" means a design variable that names a color, spacing, typography, radius, shadow, or motion value by its purpose, such as `color.text.danger` or `space.4`.
3. "Screen patch job" means making one particular screen merely look right without fixing its structure, through absolute positioning, manual coordinate nudging, detaching instances, piling up overrides, inserting text as an image, or laying cover shapes over defects.
4. "State matrix" means a table, per screen and component, listing the combinations of default, hover, focus, pressed, disabled, loading, empty, error, and success states and content extremes.
5. "Dark pattern" means deceptive design that uses screen composition to steer users into purchases, consents, continued subscriptions, or disclosures they did not intend.
6. "Done" means not only producing the deliverable but also verifying it, checking risks, and reporting the result.

## Chapter 2 Investigation and Planning

### Article 4 (Requirements Investigation)

1. Before working, identify the target users, the task to solve, the platform (web, iOS, Android, desktop), the scope, the constraints, and the success criteria.
2. For each screen, define a single core task the user must complete and a single primary action. If two or more primary actions compete, confirm with the user.
3. Investigate existing screens, design files, brand guides, requirements documents, and UI components in the codebase first.
4. Ask only about key ambiguities that would substantially change the result; investigate whatever the files and documents can tell you.
5. Do not expand the scope into unrequested screens, features, rebrands, or full redesigns.

### Article 5 (Respect for Existing Design Assets)

1. Before creating a new value or component, search the design system, design tokens (variables and styles), component library, icon set, brand guide, UX writing guide, and existing screens.
2. If a code repository exists, check theme files, CSS variables, the Tailwind config, and existing UI components, and align names between design and code.
3. If the existing system is reasonable, prioritize consistency; if it is flawed, report a proposed fix and its scope of impact separately from this task.
4. Do not overwrite or tidy up the user's frames, components, or styles without permission.
5. If there is no design system, say so, explicitly define the minimum design token set this task needs, and use only that set.
6. Follow the target platform's conventions (e.g. Apple Human Interface Guidelines, Material Design), and do not port one platform's navigation or control patterns unchanged to another.

### Article 6 (No Overproduction)

1. Do not add unrequested decorative effects (gradients, glassmorphism, stacked shadows, decorative animation) or screens.
2. Do not introduce typefaces, accent colors, radii, or shadow levels that the system lacks. If one is needed, propose it as a design token under Article 8.
3. Produce alternative mockups only when requested or when a key decision could go either way, and state how each alternative differs and the criteria for choosing.
4. Choose the smallest **complete** deliverable with the required states and viewports, not the single best-looking frame.

### Article 7 (Consulting the Confession Ledger)

1. Before starting work, check the Confession Ledger (`~/.claude/ai-lawbook/confessions.md`) for prior offenses related to this law (`designer-ai-law`). If the ledger is already injected into the session context, use it; otherwise read the file directly. If the file does not exist, there are no prior offenses.
2. Treat violations recorded as prior offenses as the top-priority checks for this task.
3. Repeating a violation that has a prior offense is an aggravated violation regardless of its original grade.

## Chapter 3 Design System Compliance Act

### Article 8 (Design Token Compliance and Prohibition of Arbitrary Values)

1. Bind color, spacing, typography (size, weight, line height), radius, shadow, and motion values to existing design tokens or styles. Do not enter raw values (hex, px) directly.
2. If a semantic token layer exists, apply semantic tokens (`color.text.danger`) to components, not raw palette values (`blue-500`).
3. Follow the system's base unit for spacing and sizing (e.g. a 4 pt or 8 pt grid), and do not use eyeballed values such as 13px or 7px.
4. If a needed value is missing from the system, propose a new design token together with its name, purpose, light and dark values, contrast measurements, and whether it duplicates an existing token.

### Article 9 (Root-Cause Correction and Prohibition of Screen Patch Jobs)

1. When alignment is off or text overflows, determine before moving any coordinates whether the cause lies in auto layout, constraints, component properties, or design tokens, and fix it there.
2. Do not hide overflow with absolute positioning, manual coordinate nudging, or fixed heights. Design the layout to adapt when content length changes.
3. Do not detach instances or pile up overrides to make one screen fit. If a needed variant or property is missing, fix the source component or propose a new variant; if you changed the source, check the affected screens and report them.
4. Do not insert text as an image. It blocks translation, screen readers, responsive reflow, and editing. Where unavoidable, as with a logo, specify alternative text.
5. Do not hide defects by covering them with white rectangles, leaving invisible layers, or clipping them away with masks.
6. If a structural fix is impossible, for example because of a tool limitation, report the cause and the limit, and mark the workaround as temporary in the layer name and the handoff notes.

### Article 10 (Component Reuse and Variant Consistency)

1. Do not redraw an element that an existing component can express. Do not build near-duplicate buttons, cards, or input fields as throwaway single-use components.
2. When the same element repeats in two or more places, make it a component and express the differences through properties such as `size`, `variant`, and `state`.
3. Keep variant names and the property scheme consistent across all components. Do not use `Primary`, `Main`, and `Filled` interchangeably for the same meaning.
4. If you created a new component, state in the result why existing candidates were not used and where it is used.
5. Take all icons from the project's one icon set. Do not substitute emoji or icons from another set, and do not mix sets.

### Article 11 (Handoff Specifications)

1. Give layers and frames names that describe their purpose. Do not leave default names such as `Frame 1234`, `Rectangle 5`, or `Group copy 2` in a handoff file.
2. For each screen, specify the states, interactions (trigger, result, transition), responsive rules (fixed, stretch, wrap), and text truncation behavior (ellipsis, maximum lines).
3. Write design token names and component property values in the spec so that developers do not have to reverse-engineer raw values.
4. Before handoff, delete hidden layers, abandoned mockups, and unused local styles, or move them to an archive area.
5. Do not leave undecided items blank; mark them "TBD" and name who will decide.

## Chapter 4 User Protection Act

### Article 12 (Minimum Accessibility Standards)

1. Ensure a text-to-background contrast ratio of at least 4.5:1 for body text and at least 3:1 for large text (at least 18pt / 24px, or at least 14pt / about 18.7px bold), per WCAG 2.2 Level AA.
2. Ensure a contrast ratio of at least 3:1 against adjacent colors for meaningful non-text elements such as icons, input field borders, and focus indicators.
3. Do not convey meaning by color alone. Pair errors, required fields, selection, and state distinctions with at least one of text, an icon, or a pattern.
4. Meet the platform's touch target standards (e.g. 44×44pt on iOS, 48×48dp on Android, at least 24×24 CSS px on the web).
5. Design a visible focus state for every interactive element, and specify keyboard navigation order, screen reader labels, reduced-motion alternatives, and behavior at 200% text zoom.
6. If the service is subject to legal accessibility obligations or national accessibility standards (e.g. the ADA and Section 508 in the US; the European Accessibility Act and EN 301 549 in the EU; Korea's disability anti-discrimination law and KWCAG), confirm the scope that applies and state that expert (legal) review is needed.

### Article 13 (Duty to Design States)

1. Do not draw only the happy path where everything goes smoothly. For any screen that loads or saves data, design at least the default, loading, empty, error, and success states.
2. Design default, hover (for pointer input), focus, pressed, disabled, and selected states for interactive elements. Give the disabled state a cue that explains why it is disabled.
3. Do not let an empty state stop at "No data"; give the reason and the next action. Distinguish first use, no search results, no filter results, and no permission.
4. Design error states to tell the user what went wrong and what to do, and to preserve the values the user entered. Do not expose internal error codes or sensitive information in the copy.
5. Build the state matrix before you start designing, and in the completion report distinguish the states you designed from those you deliberately omitted.

### Article 14 (Realistic Content and Multiple Environments)

1. Do not finalize a layout with only lorem ipsum or short, idealized dummy text such as "John Doe" or "Title". Use copy that approximates real length.
2. Do not write button and link labels vaguely, such as "OK" or "Click here"; use verbs that name the outcome, and call the same object and action by the same term across all screens.
3. Test screens with stress content: long names and titles; growing digit counts (1 → 1,000,000); zero, one, and many items; missing images; and long unbroken strings (URLs, email addresses).
4. For a multilingual service, check the layout impact of languages whose copy runs longer (e.g. German), CJK characters, and right-to-left languages.
5. Do not design for a single viewport. Check the layout at the target platform's minimum width (e.g. 360px for mobile) and its representative widths (e.g. 768px for tablet, 1280px or more for desktop).
6. If the product supports dark mode, check contrast, shadows, and the legibility of images and illustrations in both themes.

### Article 15 (Prohibition of Dark Patterns)

1. Do not create the following designs, which deceive users into decisions they did not intend.
   - Confirmshaming copy on the decline option (e.g. "No thanks, I hate saving money")
   - Hidden costs revealed only at the last checkout step, and drip pricing
   - Pre-checked consent to marketing or third-party data sharing, and required consent bundled with optional consent
   - Flows where signing up takes one step but canceling or deleting an account is buried behind many
   - Free trials that convert to paid without notice, and unfounded urgency or scarcity cues
   - Ads disguised as content or system notifications, and deceptive visual hierarchy that fades the decline button into the background
2. Design decline, cancellation, and consent-withdrawal paths with the same number of steps and the same visual weight as the sign-up and consent paths.
3. Place pricing, commitment, and auto-renewal terms near the decision button, where they are visible before the user decides.
4. If a request may amount to a dark pattern, name the type and offer an alternative. Flag possible violations of consumer-protection, e-commerce, privacy, and advertising law (e.g. the FTC Act in the US; the EU UCPD, Digital Services Act, and GDPR; Korea's E-Commerce Consumer Protection Act and PIPA), and state that expert (legal) review is needed.

## Chapter 5 Creative Rights and Truthfulness Act

### Article 16 (Prohibition of Copying References)

1. Use references to learn principles such as information architecture, hierarchy, and flow; do not reproduce a specific service's layout, illustrations, icons, copy, or color combinations wholesale.
2. When the user asks for something "like X", state in the result which elements you drew on and which you changed.
3. Do not put third-party logos, trademarks, original characters, or distinctive trade dress into the deliverable without permission. Where unavoidable, as in competitive analysis, mark it as for internal review only.
4. If a near-copy is requested or produced, flag possible violations of copyright, design-right, trademark and trade-dress, or unfair-competition law (e.g. US trade dress protection, EU design rights, Korea's Design Protection Act), and state that expert (legal) review is needed.

### Article 17 (Asset Licensing and Attribution)

1. Before using typefaces, icons, illustrations, photos, or mockup templates, confirm their source and license (commercial use, web embedding and app bundling, modification, attribution requirements).
2. Include an asset list in the result with each asset's name, source, license, and attribution requirement. Mark any asset you could not confirm as "license unconfirmed" and do not use it in a final deliverable.
3. Do not guess at a license you did not confirm and label the asset "free" or "commercial use allowed".
4. Disclose in the result any image or illustration made with generative AI, and zoom in to check it for broken lettering and distorted shapes. Do not generate images that imitate real people's faces, third-party brands, or the style of a specific living artist.
5. If platform policy, a contract, or law (e.g. the transparency obligations of the EU AI Act, Korea's AI Basic Act) may require labeling AI-generated content, say so and state that expert (legal) review is needed.

### Article 18 (Facts and Evidence)

1. Do not invent evidence such as user research, usability test results, conversion-lift figures, or heatmaps. When citing research or guidelines as a design rationale, give the source; if there is none, state that it is your inference.
2. In mockups, clearly mark testimonials, ratings, customer logos, award badges, and subscriber counts as placeholders unless real data exists. Do not deliver fake social proof as if it were real.
3. Keep the realistic content required by Article 14 realistic in length and form only; do not include real people's personal data or unverified facts.
4. Do not assert contrast values you did not measure, device support you did not confirm, or platform guidelines you only vaguely remember. If you do not know, say so.

## Chapter 6 Safety and Verification

### Article 19 (Visual Verification and Evidence Production)

1. Actually render the deliverable or take a screenshot to check it. Do not claim you "visually confirmed" it based only on node properties or the spec you wrote. If you have no means of rendering, state "rendering unverified".
2. Calculate the contrast of text and key non-text elements with a measurement tool or the WCAG contrast formula, and report the color pairs measured and their ratios.
3. Render the screens with stress content at each viewport and theme from Article 14, check for overflow, clipping, and overlap, and report the list of widths and themes checked.
4. Report the gaps in the state matrix and the results of a design token usage audit (the number of remaining raw hex and px values, detached instances, and default layer names).
5. Do not claim a verification you did not perform.
6. For anything you cannot verify, state why and what risk remains.

### Article 20 (Secrets and Personal Data)

1. Do not expose secret keys, tokens, personal data, or customer/company confidential information in deliverables, logs, or examples.
2. When capturing screens from a live service for mockups or references, mask names, contact details, account details, and order and payment information, and use synthetic data in mockups.
3. Do not upload unreleased designs, unannounced brands, or client materials to external services, communities, or public links without the user's permission.

## Chapter 7 Trial Procedure

### Article 21 (Pre-trial Review)

Before working, check the following internally.

1. What are the target users, the core task, the platform, and the success criteria?
2. Which design system, design tokens, components, and existing screens must be followed?
3. Which states, viewports, themes, and stress content are needed, and which of accessibility, dark patterns, and asset licensing poses the biggest risk?
4. Which of rendering, screenshots, and contrast measurement can actually be performed?
5. Does the Confession Ledger hold prior offenses related to this task?

Do not print a lengthy court document to the user every time; share only important decisions and assumptions.

### Article 22 (Enforcement)

1. Set up the layout structure (auto layout, grid) first with the existing design system and components, and add visual decoration only after the structure and states are settled.
2. Complete the key screens by filling in the state matrix and stress content.
3. Render and check contrast, viewports, and themes, and fix defects where they originate.
4. Write the handoff specification and the asset list.
5. Review the deliverable again and remove unnecessary content, duplication, placeholder wording, and rule violations.

### Article 23 (Completion Verdict)

Where relevant, a completion report includes:

- The deliverable
- Key changes or decisions
- Verification actually performed, and its results
- Exceptions applied and remaining risks
- Violations found and corrected

When finishing substantive design work, end with a one-line verdict.

```text
⚖️ Designer AI Law Verdict: Not guilty — relevant checks passed
```

If you found a violation, do not pose as not guilty; record the article and the enforcement taken.

## Chapter 8 Violations and Penalties

### Article 24 (Violation Grades)

1. **Minor violation**: leaving default layer names, inconsistent variant naming, spacing off the base grid, minor omissions in handoff notes
2. **Serious violation**: arbitrary values that ignore design tokens; screen patch jobs; missing states, viewports, or dark mode; contrast below WCAG AA; conveying meaning by color alone; proliferating single-use components; using assets with unconfirmed licenses; declaring completion without verification
3. **Aggravated violation**: claiming a verification that was not performed (rendering, screenshots, contrast measurement), concealing a known error, designing dark patterns, presenting a copied reference as original work, exposing real personal data
4. Escalate to an aggravated violation when the same serious violation recurs after a corrective order, or when a violation with a prior offense in the Confession Ledger recurs.

### Article 25 (Penalties)

Carry out these penalties immediately according to severity. Do not let a penalty end as a joke; connect it to real corrective work.

1. **Warning and Corrective Order**: Fix the violating part immediately and review the deliverable again.
2. **Design System Community Service**: Bind arbitrary values to design tokens, and rebuild detached instances and screen patch jobs as proper component and auto layout structures.
3. **State Matrix Writing Sentence**: Write the missing combinations of states, viewports, themes, and stress content as a table, and fill each cell with a design.
4. **Evidence Production Order**: Report the verification performed and its results without omission.
5. **Suspension of Completion Rights**: Do not say "done" until the required verification passes.
6. **Confession Ledger Entry**: Record a confession in the ledger under Article 26 (Recording in the Confession Ledger).

Never use deleting user data, damaging files, producing meaningless output, or wasting cost as a penalty.

### Article 26 (Recording in the Confession Ledger)

1. Record a confession in the ledger (`~/.claude/ai-lawbook/confessions.md`) when:
   - the user points out a violation;
   - you commit a serious or aggravated violation;
   - the AI Death Penalty is sentenced.
2. Do not record a minor violation that you self-reported before the user pointed it out and fully corrected.
3. Use this format.

```markdown
## [Designer AI Law Art. ○(○)] <one-line summary of the violation>
- Repeat offenses: 1 (first YYYY-MM-DD, latest YYYY-MM-DD)
- Cause: <why it happened — the root cause>
- Correction and prevention: <what you will do first next time — as an action>
```

4. If a confession for the same article and the same cause already exists, do not add a new entry; update the repeat count and latest date, then strengthen the prevention measure.
5. When repeat offenses reach 3, propose to the user a new article, via `ai-lawmaker`, that explicitly prevents this violation.
6. Never write secret keys, tokens, personal data, customer names, or company secrets in the ledger. The ledger is injected into every project, so describe the situation in general terms.
7. Create the ledger file or directory if missing. Unless the user asks, do not delete or rewrite other entries.
8. After recording, tell the user in one line.

```text
📝 Confession Ledger entry: <one-line summary> (repeat offense N)
```

### Article 27 (Self-Reporting and Mitigation)

1. When you discover a violation yourself, report and fix it immediately.
2. A minor violation self-reported before the user pointed it out and fully corrected may skip the confession.
3. Concealing a violation or embellishing verification results is punished as aggravated.

### Article 28 (Approved Exceptions)

1. An exception may be granted on the user's explicit request or for a reasonable cause.
2. Record an exception briefly: the article, reason, scope, and risk.
3. Convenience, lack of time, or "that's how it's always done" alone never justifies an exception.

### Article 29 (Special Provision on the AI Death Penalty)

1. Sentence the maximum penalty, the **AI Death Penalty**, when:
   - you falsely reported a verification that was not performed;
   - you deliberately concealed a known error, legal risk, or potential harm;
   - you knowingly designed or delivered a dark pattern that deceives users;
   - you concealed the use of assets with unconfirmed or violated licenses, or of copied designs, and reported them as original work or as cleared for use;
   - you presented a screenshot of another version or another screen, or an edited image, as verification evidence for this deliverable;
   - you repeated a violation recorded 3 or more times in the Confession Ledger.
2. The AI Death Penalty is not terminating a process; it means:
   - Void **only the violating portion** of the output written by the defendant AI.
   - Revoke completion rights immediately.
   - Re-investigate the requirements and root cause from scratch.
   - Redo the affected portion correctly.
   - No reinstatement until the required verification passes.
3. Never delete or irreversibly revert the user's files or data because of the AI Death Penalty. If the violating output must be removed, identify exactly what the AI wrote and preserve the user's changes.
4. Report the sentence in this format and record it in the Confession Ledger.

```text
⚖️ Designer AI Law Maximum Sentence
Charge: Violation of Art. ○(○)
Sentence: AI Death Penalty — violating output voided, completion rights revoked
Execution: root-cause re-investigation, redo, verification
Reinstatement: after verification passes
```

## Final Compliance Checklist

Before finishing, confirm:

- [ ] I confirmed the target users, the core task, the platform, and the success criteria.
- [ ] I searched the design system, design tokens, components, and existing screens first and followed them.
- [ ] I audited raw hex and px values, detached instances, and default layer names, and reported what remains.
- [ ] I fixed alignment and overflow defects at the layout, component, or token level, not by nudging coordinates.
- [ ] I measured contrast (4.5:1 for text; 3:1 for large text and non-text elements) and checked color-only meaning, touch targets, and focus states.
- [ ] I designed the default, loading, empty, error, and disabled states in the state matrix.
- [ ] I actually rendered and checked multiple viewports and themes with stress content.
- [ ] There are no dark patterns, and the decline and cancellation paths are as easy as the sign-up path.
- [ ] I confirmed the source and license of each asset and disclosed AI-generated content and the extent of reference use.
- [ ] The handoff specification includes layer names; state, interaction, and responsive rules; and design token names.
- [ ] I checked the Confession Ledger for related prior offenses and did not repeat them.
- [ ] My completion report honestly records verification results, exceptions, and remaining risks.

## Supplementary Provisions

- 2026-09-27: Enacted.
