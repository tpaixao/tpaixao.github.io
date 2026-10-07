---
name: quarto-blog-posts
description: Create and edit Quarto blog posts (.qmd / .ipynb) for this site (tpaixao.github.io). Encodes Quarto qmd/ipynb syntax rules with special attention to figure and table captions, plus Tiago's layout preferences (all code folded, captions in the margin, jupytext qmd<->ipynb pairing). Use when writing a new post, editing figures/tables/captions, or rendering draft posts.
---

# Quarto blog posts (this site)

## Scope

Anything in `blog/`: creating posts, editing prose/code cells, adding figures or
tables with captions, cross-references, and rendering drafts.

## Tiago's standing preferences (apply to every post)

1. **Code is always folded.** Put in the post header:
   ```yaml
   format:
     html:
       code-fold: true
   ```
   Per-cell overrides are allowed: `#| code-fold: false` to force one cell open,
   `#| echo: false` to hide a cell's code entirely.
2. **All captions in the margin.** Put in the post header:
   ```yaml
   cap-location: margin
   ```
   (This covers both figure and table captions. `fig-cap-location` / `tbl-cap-location`
   are the per-type variants; recent older posts used `fig-cap-location: margin` only.)
   Keep caption text short — margin space is narrow.
3. **Every numbered figure/table gets a `fig-`/`tbl-` label + caption.** Cross-reference
   it in the prose with `@fig-...` / `@tbl-...` instead of writing "Figure 1" by hand.

## File layout & pairing

- Posts live in `~/projects/tpaixao.github.io/blog/` as `.qmd`, jupytext-paired
  with a `.ipynb` twin (`formats: qmd:quarto,ipynb`). **Edit the `.qmd`, then sync**
  so the notebook twin stays in step:
  ```bash
  cd ~/projects/tpaixao.github.io/blog && mamba run -n jupyter jupytext --sync <post>.qmd
  ```
- Post images: `blog/images/`; cover images: `blog/cover_images/`.
- Kernel: `main` (display name "Python 3 (main)"). Do not let JupyterLab rewrite
  the kernelspec to `conda-env-main-py` — Quarto can't resolve it; check after
  editing in JupyterLab.

## New-post skeleton

File name: kebab-case, `<kebab-slug>.qmd`.

```markdown
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
jupyter:
  jupytext:
    formats: qmd:quarto,ipynb
    text_representation:
      extension: .qmd
      format_name: quarto
      format_version: '1.0'
      jupytext_version: 1.19.5
  kernelspec:
    display_name: Python 3 (main)
    language: python
    name: main
---

Opening paragraph...

## Section

![Short caption text](images/plot.png){#fig-my-plot}

See @fig-my-plot for ...
```

Optional cover art: `image: cover_images/cover_<slug>.png` plus
`title-block-banner: cover_images/cover_<slug>.png` (`image:` also feeds the
blog-listing thumbnail and the social/og card — see reference.md §10).

Categories in use: Methods & Inference, Decentralized Infrastructure,
AI & Knowledge Work, Engineering Notes. Keep `draft: true` while unpublished.

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
cd ~/projects/tpaixao.github.io/blog
mamba run -n jupyter quarto render <post>.qmd     # needs jupyter on PATH; quarto 1.10+ also at /usr/local/bin/quarto
```

- Draft posts render as empty stubs — to eyeball figures, copy the post to a temp
  file with `draft: false`, render, then delete.
- Notebook cells are NOT re-executed on render by default (saved outputs are used);
  pass `--execute` only if needed.

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

Prose extras — footnotes (`reference-location: margin` pairs with the margin
captions), citations (`bibliography:` paths are relative to the POST, i.e.
`../MyPapers2026.bib`), callouts, social cards, aliases: `reference.md` §§7–10.
Full caption/cross-ref detail (ipynb conventions, subfigures/subtables, div
nesting, crossref options): `reference.md` §§1–6.