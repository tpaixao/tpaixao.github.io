---
name: blog-prose-style
description: Tiago's writing rules for blog-post prose. Work-in-progress, rules accumulate. Current hard rules - no em-dashes, no "it's not X, it's that" corrective constructions. Use when drafting, editing, re-voicing, or reviewing any blog post prose, and always as a final style check before presenting prose to him.
---

# Blog prose style

**Status: work-in-progress.** This file is the registry. When Tiago rejects or
rewords a construction in a draft, add the rule (with date and example) instead
of arguing. Rules plus examples, not essays.

## Hard rules

### 1. No em-dashes `—` (2026-10-05)

The character `—` never appears in post prose. Rework the sentence: comma,
period, colon, parentheses, or restructure.

- En-dash `–` stays allowed for numeric ranges only (`pp. 33–35`).
- Hyphen for compounds (`Wright-Fisher`, `first-audio`) as usual.
- The mojibake cousin (`â` with invisible continuation bytes) counts as a
  violation; it is a double-encoded em-dash. Fix the encoding, then apply this
  rule.

Check before showing a draft: `grep -n "—" <post>.qmd` must come back empty.

### 2. No "it's not this, it's that" (2026-10-05)

No corrective-redirection constructions, in their **entire family**:

- `It's not X, it's Y` / `isn't X, it's Y`
- `not X, but Y`
- `X, not Y` (e.g. "…encodes bench layout, not biology")
- `stops being X and becomes Y`

Why: the move elevates a claim by staging a straw denial before it, and it is
the most recognizable LLM tic in prose. State the point directly.

Fixes, in order of preference:

1. **Assert only the claim.** Drop the denial half. ("The unit of honesty is
   the joint posterior of all three quantities.")
2. If the contrast genuinely matters, put the context after a colon or in
   parentheses.
3. Never patch it into `rather than` if the sentence is really doing rule-2
   work; rewrite the sentence.

## Watch list (not banned; rewrite when the sentence leans on them)

- `rather than` — fine for a genuine trade-off between two real options;
  rewrite when it carries the corrective emphasis of rule 2.

## Liked constructions (use them; never "fix" these away)

- `not only X but also Y` — Tiago likes this one (2026-10-05). Use it where
  an additive emphasis genuinely serves the sentence; the `also` is welcome.
  Rules 1–2 are never a license to strip it: only the em-dashes and the
  corrective-denials go.
- `Photography did not make abstraction possible. It made abstraction urgent.`
  (2026-10-07, `after-the-camera-after-the-machine`) — sanctioned exception to
  rule 2, load-bearing thesis sentence Tiago restored after it was rewritten.
  Do not apply rule 2 to it in future passes.

## Self-check before showing any prose to Tiago

1. `grep -n "—" <post>.qmd` → empty.
2. Search for `, not `, `not .* but `, `it's not`, `stops being`.
3. Read each hit; if it is the corrective emphasis move, rewrite per rule 2.
   A `not only … but` hit is additive and welcome — keep it (add `also` if the
   rhythm wants it).

Em-dashes and corrective constructions are AI tics: never let your own drafts
carry them, and treat any you find in Tiago's drafts as fixes, not style.

## Voice signatures (his own, from the corpus; use, and use sparingly)

Demonstrated in `blog/`:

- Open at a **concrete tension**: a number that misbehaves, a mistake, an
  artifact pulled from the archive. Never with a survey of the field.
- `"I"` for the work, `"we"` only when walking the reader through the math.
- **Honesty with numbers**: name the false positives, the FDR rise, the
  uncovered cases. Specific beats hedged ("20 of 20 called, at the price of 7
  false positives").
- Narrative section names, and a **Take-home messages** closer.
- Old work is archaeology (DAWN, the prehistory post, the 2020 archive notes),
  not embarrassment.
- Runnable posts where possible; say explicitly what regenerates and how fast.

## Rule log

| Date | Rule | Source |
|---|---|---|
| 2026-10-05 | no em-dashes | ground rules given by Tiago |
| 2026-10-05 | no "not-this, it's-that" family | ground rules given by Tiago |
| 2026-10-05 | watch list: rather than | inferred as adjacent; not banned |
| 2026-10-05 | `not only X but also Y` welcomed; removed from watch list into Liked | Tiago correction, same day |

## Violation → fix examples (from this repository, 2026-10-05)

| Violation | Fix |
|---|---|
| `…NUTS — so the answer stops being a number and becomes its distribution.` | `…NUTS. The result is a distribution over all three unknowns, and any single number quoted from it arrives with the spread that justifies it.` |
| `…encodes bench layout, not biology.` | `…encodes bench layout; biology never enters it.` |
| `…quantities — the test error rates — that were least firmly known.` and `sees not only a prevalence estimate but the width…` | `…quantities that were least firmly known: the test error rates.` and `sees not only a prevalence estimate but also the width…` — drop the dashes, keep and complete the liked doublet |
| `the joint posterior is the unit of honesty, not three separate point estimates.` | `the joint posterior over the three of them is the unit of honesty.` |