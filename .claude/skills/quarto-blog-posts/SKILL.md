---
name: quarto-blog-posts
description: Create and edit Quarto blog posts (.ipynb) for this site (tpaixao.com). Encodes Quarto notebook syntax rules with special attention to figure and table captions, plus Tiago's layout preferences (all code folded, captions in the margin). Notebooks are the single source of truth — qmd twins were retired (2026-10-08). Use when writing a new post, editing figures/tables/captions, or rendering draft posts.
---

# Quarto blog posts (this site)

## Scope

Anything in `blog/` (posts) and `projects/` (project docs): creating content,
editing prose/code cells, figures/tables with captions, cross-references,
rendering drafts.

## Tiago's standing preferences (apply to every post)

1. **Code is always folded.** Put in the post front matter:
   ```yaml
   format:
     html:
       code-fold: true
   ```
   Per-cell overrides are allowed: `#| code-fold: false` to force one cell open,
   `#| echo: false` to hide a cell's code entirely.
2. **All captions in the margin.** Put `cap-location: margin` in the front
   matter. (Covers both figure and table captions; `fig-cap-location` /
   `tbl-cap-location` are per-type variants. Keep caption text short —
   margin space is narrow.)
3. **Every numbered figure/table gets a `fig-`/`tbl-` label + caption.**
   Cross-reference in prose with `@fig-...` / `@tbl-...`, never "Figure 1" by hand.

## File layout & source of truth

- **Notebooks are the single source of truth.** Posts live in
  `~/projects/tpaixao.com/blog/` as `.ipynb` with their YAML front matter in
  the **first cell** (raw or markdown cell starting with `---`; both render —
  our posts use both forms). Project docs live in `projects/` the same way.
- **No jupytext pairing, no qmd twins, no `jupyter: jupytext:` stamps.**
  All were retired 2026-10-08 (commits 5d5ca8e→dbff5fb). Never re-add them;
  never keep both an `.ipynb` and a `.qmd` of the same post (double render +
  duplicate listing entries).
- Occasionally qmd IS preferable (heavy markdown, no computation) — then just
  write that post as `.qmd`. To switch an existing post:
  `quarto convert post.ipynb` → inspect the `.qmd` → delete the `.ipynb`.
- Site pages (`about.qmd`, `index.qmd`, `cv.qmd`, `blog.qmd`,
  `publications.qmd`) remain `.qmd`.
- Post images: `blog/images/`; cover images: `blog/cover_images/`.
- Kernel: the notebook's metadata kernelspec must be `main` (display name
  "Python 3 (main)"). Do not let JupyterLab rewrite it to
  `conda-env-main-py` or `python3` — Quarto can't resolve either reliably;
  **check after every JupyterLab editing session**.

## New-post skeleton

File name: kebab-case. Create `blog/<kebab-slug>.ipynb` in JupyterLab, then make
the **first cell a raw cell** containing:

```yaml
---
title: Post title here
description: One-sentence summary (quote only if it contains a colon)
categories:
  - Methods & Inference
date: '2026-10-03'
draft: true
cap-location: margin
# reference-location: margin         # footnotes also in the margin
# bibliography: ../MyPapers2026.bib  # path is relative to the POST
# csl: ../nature.csl                 # optional; default = Chicago author-date
format:
  html:
    code-fold: true
---
```

Then set the notebook kernel to **"Python 3 (main)"** (notebook metadata
`kernelspec.name = "main"`). No `jupyter:` block is needed in the YAML — the
notebook's own kernelspec drives execution; if you do add one it must be
`jupyter: {kernelspec: {name: main}}` (note the single nesting level).

Optional cover art: `image: cover_images/cover_<slug>.png` plus
`title-block-banner: cover_images/cover_<slug>.png` (`image:` also feeds the
blog-listing thumbnail and the social/og card — see reference.md §10).

Categories in use: Methods & Inference, Decentralized Infrastructure,
Scientific Infrastructure, Tools & Apps, AI & Knowledge Work,
Engineering Notes. Keep `draft: true` while unpublished.

## Figure & table caption syntax (the rules that matter most)

**Figures**
- Markdown image alone in a paragraph ⇒ it is a figure; the alt text is its caption:
  `![Caption text](images/plot.png)`
- Numbered + cross-referenceable ⇒ caption + label with `fig-` prefix:
  `![Caption text](images/plot.png){#fig-my-plot}` … referenced as `@fig-my-plot`.
- Caption ≠ alt text ≠ title: `![Caption](plot.png "Title"){fig-alt="Alt text"}`
  — always add `fig-alt` for accessibility.
- From an executed code cell:
  ````markdown
  ```{python}
  #| label: fig-my-plot
  #| fig-cap: "Short margin caption"
  #| fig-subcap:                 # only for multi-figure cells
  #|   - "Panel a"
  #|   - "Panel b"
  #| layout-ncol: 2
  ...plotting code...
  ```
  ````
- Any block can be a figure via a div; **the last paragraph inside the div is the caption**:
  ```markdown
  ::: {#fig-my-plot}
  ![](images/plot.png)
  Caption text
  :::
  ```
- Figure captions render **below** the figure by default — our `cap-location: margin`
  moves them to the sidebar instead.

**Tables**
- Pipe table + caption line **below the table in the source** (starts with `:`),
  label in braces at the end:
  ```markdown
  | Col1 | Col2 |
  |------|------|
  | A    | B    |

  : Short caption {#tbl-my-table}
  ```
- From a code cell: `#| label: tbl-my-table` + `#| tbl-cap: "Short caption"`.
- Table captions render **above** the table by default (opposite of figures!) —
  again `cap-location: margin` moves them to the sidebar.
- Complex cell content ⇒ list table, caption = **first** paragraph inside the div:
  ```markdown
  ::: {#tbl-my-table .list-table}
  Short caption

  - - Fruit
   - Price
  - - Apple
   - 1.20
  :::
  ```

**Cross-references** (both kinds): `@fig-x` → "Figure 1", `[@fig-x; @tbl-y]` groups,
`[-@fig-x]` number only, `@Fig-x` capitalized. Section refs need `{#sec-name}` on the
heading **and** `number-sections: true`.

## Rendering / validation

```bash
cd ~/projects/tpaixao.com
mamba run -n jupyter quarto render blog/<post>.ipynb   # quarto 1.10+ also at /usr/local/bin/quarto
```

- Drafts render FULLY (`draft-mode: unlinked` since 2026-10-07): ~30KB page +
  draft alert banner, still unlinked from listing/search/sitemap. Tiago usually
  keeps `quarto preview` running — live-reloads saved edits, edit in place.
- Execution: `_quarto.yml` sets `execute: {freeze: auto, cache: true}` site-wide.
  Unchanged posts replay frozen outputs (no kernel starts); a changed notebook
  re-executes wholesale on the next render (grain is the NOTEBOOK, not the
  cell). Prose edits alone never re-run code. `--execute` forces fresh runs.
- `*.ipynb` is in `project.render` — notebooks are first-class site sources.

## Gotchas baked in from experience & docs

- Labels must be lowercase, no `_`, and start with `fig-`/`tbl-`/`sec-`/`eq-`.
  Reserved prefixes: fig, tbl, lst, tip, nte, wrn, imp, cau, thm, lem, cor, prp,
  cnj, def, exm, exr, sol, rem, alg, eq, sec.
- A cross-referenceable entity needs BOTH label and caption — a bare `{#fig-x}`
  with no caption text doesn't number.
- Never put a `{#fig-...}` label on both the image and an enclosing fig div.
- Lists need a full blank line above them (unlike GitHub/Jupyter markdown).
- No blank lines inside `$$ ... $$` display math.
- Markdown-cell image captions show correctly in Quarto output, but the Jupyter UI
  only shows alt text (by design, not a bug).
- Shortcodes (`{{< ... >}}`) don't work inside grid tables.
- Jupyter-cell figures get a hard `width` attribute = `figsize × fig-dpi`
  (default `fig-dpi` 160) and **no** `img-fluid` class — at defaults a ~7.8in
  figure renders ~1250px wide and overflows the ~500–800px content column.
  Since 2026-10-07 the site `styles.css` clamps all figures
  (`max-width: 100%; height: auto`), but in code cells prefer
  `#| fig-dpi: 96` so text renders at true point size instead of being
  shrunk by the clamp. PNG is saved retina (dpi × 2) and cropped tight
  (`bbox_inches='tight'`), so attr tracks content, not canvas.
- `fig-width`/`fig-height`/`fig-dpi` have **no cell-level effect** with the
  Jupyter engine — set them at document level (front matter) only.
- After editing a notebook in JupyterLab, diff the metadata: kernelspec must
  still be `main`, and the YAML front matter cell must still start with `---`.

Prose extras — footnotes (`reference-location: margin` pairs with the margin
captions), citations (`bibliography:` paths are relative to the POST, i.e.
`../MyPapers2026.bib`), callouts, social cards, aliases: `reference.md` §§7–10.
Full caption/cross-ref detail (notebook conventions, subfigures/subtables, div
nesting, crossref options): `reference.md` §§1–6.