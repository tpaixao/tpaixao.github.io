# Quarto syntax reference: .qmd & .ipynb — figures, tables, captions

Sources: quarto.org docs (Markdown Basics, Figures, Tables, Cross References,
Cross-Reference Div Syntax, Code Cells: Jupyter, VS Code Notebook Editor,
Jupyter Notebook Options) and quarto-dev/quarto-cli issue #4435 (ipynb caption behavior).

## 1. Document structure

### .qmd
- YAML header delimited by `---` fences; then Pandoc-based markdown.
- Executable cells: fences with language in braces ```` ```{python} ```` … ` ``` `;
  cell options as `#|` YAML comment lines at the **very top** of the cell.
- Static code (highlighting only): ```` ```python ```` or ```` ```{.python} ````
  (the `{.lang}` form accepts attributes, e.g. `filename=`).
- Fenced divs: `::: {#id .class key="val"}` … `:::`; nestable (outer fence may
  use more colons, e.g. `::::`); closing fence needs no attributes.
- **Attribute order everywhere: id, then classes, then key-values.**
  Valid: `[text]{#id .class key="val"}`. Invalid: `[text]{.class key="val" #id}`.
- Quarto requires a **whole blank line above any list** or it renders as plain text.
- Line breaks: newline in a paragraph = soft break; hard break = trailing `\`.
- Math: `$...$` inline, `$$...$$` display (no blank lines between the `$$`);
  label display math with `{#eq-name}` placed after the closing `$$`.
- Raw blocks: ```` ```{=html} ````, ```` ```{=latex} ````, ```` ```{=typst} ````.
- Shortcodes: `{{< video ... >}}`, `{{< pagebreak >}}`, `{{< include file.qmd >}}`
  (included files conventionally underscore-prefixed).

### .ipynb (Jupyter)
- **First cell must be a Raw cell** holding the YAML header (title, format,
  jupyter/jupytext block, etc.).
- Markdown cells accept any Quarto/Pandoc markdown (callout divs, cross-refs, math).
- Code-cell options: `#|` comment lines at the very top of the cell, OR in the
  cell's `metadata` (JSON); `#|` values win over metadata. Tag shortcuts exist:
  `hide-cell`, `hide-code`, `show-code`, `hide-output`, `show-output`,
  `hide-warnings`, `remove-cell`.
- Render note: `quarto render notebook.ipynb` does **not** re-execute by default
  (use `--execute` or `execute: enabled: true`). Notebook is converted to
  markdown, then processed by Pandoc.
- `quarto convert file.ipynb` ⇄ `file.qmd` converts both ways.
- Jupyter-specific figure options: `fig-width`/`fig-height`/`fig-dpi` have **no
  cell-level effect** with the Jupyter engine — set them at document level only.

## 2. Figures and captions

### Implicit-figure rule
An image alone in a paragraph = a figure; the **alt text becomes the caption**:
```markdown
![Caption text](images/plot.png)
```
Unlabeled captioned figures are unnumbered in HTML (Pandoc auto-numbers in PDF).

### Cross-referenceable figures
Caption + label starting with `fig-` (must be all lowercase; no `_`):
```markdown
![Short caption](images/plot.png){#fig-my-plot}
...
See @fig-my-plot.
```
Both a label AND a caption are required — the presence of `{#fig-...}` alone does
not create a numbered figure.

Attributes on the image (space-separated inside `{}`):
| Attribute | Purpose |
|---|---|
| `fig-alt` | accessibility alt text (screen readers) |
| `fig-align` | `left` / `center` (default) / `right` |
| `width` / `height` | `300` px, `80%`, `4in` |
| `fig-scap` | short caption for List of Figures (LaTeX only) |
| `fig-pos` / `fig-env` | LaTeX placement/environment |
| `fig-link` | hyperlink target |

Caption, title, and alt are independent: `![Caption](p.png "Title"){fig-alt="Alt"}`.
To show the caption as alt text instead, end the line with `\`.

### From code cells
````markdown
```{python}
#| label: fig-my-plot
#| fig-cap: "Margin caption"
#| fig-alt: "Alt text"
#| fig-subcap:              # multi-figure cells only
#|   - "Panel a"
#|   - "Panel b"
#| layout-ncol: 2
...code producing plots...
```
````
- `fig-subcap` labels auto-generate `@fig-my-plot-1`, `-2`, …; use
  `fig-subcap: true` for bare "(a)" identifiers without text.
- `fig-cap` can be a list (one caption per output) when no main caption is wanted.

### Div syntax (any content as a figure)
```markdown
::: {#fig-my-plot}
ANY markdown here (image, iframe, video shortcode, code cell, diagram)
Caption text
:::
```
The **last paragraph in the div is the caption**. Use it for videos, iframes,
mermaid/graphviz diagrams, or mixed content.

### Subfigures
```markdown
::: {#fig-panels layout-ncol=2}

![Sub cap a](a.png){#fig-panel-a}

![Sub cap b](b.png){#fig-panel-b}

Main caption
:::

See @fig-panels, especially @fig-panel-b.
```
Blank lines between images are required (they delimit paragraphs, hence separate
figures). Reference forms: "Figure 1", "Figure 1 (a)".

### Caption placement
- Figure captions default to **below**; `fig-cap-location: top | bottom | margin`
  (document option or per-cell) — this site uses **margin** globally via
  `cap-location: margin`.
- With `echo: true` + PDF output, executed figures default to `fig-pos: 'H'`.

## 3. Tables and captions

### Pipe tables (workhorse)
```markdown
| Col1 | Col2 |
|------|------|
| A    | B    |

: Short caption {#tbl-my-table}
```
- Caption lives **in the source below the table**, starts with `:`, label `{#tbl-...}`
  at its end; label is mandatory for cross-referencing.
- It **renders above the table by default** (opposite of figures) — overridden by
  `cap-location: margin` on this site.
- Alignment via colons in the separator row (`:---`, `:---:`, `---:`).
- Columns don't need to be aligned in source; pipes only delimit cells.
- No block content in cells; column dash-count hints relative widths
  (`---|-` ≈ 75/25). Explicit widths: `: {tbl-colwidths="[75,25]"}`
  (works with an empty caption too). Classes on the caption: `{.striped .hover}`.

### Grid tables
`+---+---+` boxes with `===` under the header; allow block content in cells;
same `: Caption {#tbl-...}` line below. Shortcodes are NOT supported inside.

### List tables (complex cells, easy syntax)
```markdown
::: {#tbl-my-table .list-table}
Short caption                      ← caption is the FIRST paragraph

- - Fruit
 - Price
- - Apple
 - 1.20
:::
```
- `header-rows=0` to drop the header; `aligns="l,r"`; `tbl-colwidths="[75,25]"`.
- Cells may contain nested lists/code blocks (mind indentation).
- Cell merges: `[]{colspan=2}` / `[]{rowspan=2}` as first inline in the cell.

### HTML tables
Raw ```` ```{=html} ```` blocks with `<table>`, `<caption>`, `<td colspan>` etc.
Quarto converts them to markdown for every format. Embed live markdown/cross-refs
inside HTML captions via `<span data-qmd="…">`. Disable processing per cell
(`#| html-table-processing: none`) or globally.

### Computational tables
````markdown
```{python}
#| label: tbl-my-table
#| tbl-cap: "Margin caption"
#| tbl-subcap:               # multiple tables in one cell
#|   - "Cars"
#|   - "Pressure"
#| layout-ncol: 2
...code printing 2+ markdown/HTML tables (use display() for >1 output in Jupyter)...
```
````
Sub-table labels come from `tbl-subcap`; `tbl-subcap: true` for bare "(a)".

### Caption placement
`tbl-cap-location: top | bottom | margin`; default `top`. This site: margin.

## 4. Cross-references

| Element | Label prefix | Example |
|---|---|---|
| Figure | `fig-` | `@fig-my-plot` |
| Table | `tbl-` | `@tbl-my-table` |
| Section | `sec-` | heading attr `## Intro {#sec-intro}` (needs `number-sections: true`) |
| Equation | `eq-` | `{#eq-pyth}` after `$$…$$` |
| Listing | `lst-` | `#| lst-label: lst-x` + `#| lst-cap:` |
| Note/Tip/… callout | `nte-`/`tip-`/`wrn-`/`imp-`/`cau-` | div id |
| Theorem | `thm-` (lem-, cor-, prp-, cnj-, def-, exm-, exr-, sol-, rem-, alg-) | div id + `## Name` inside |

Reference forms: `@fig-x` (Figure 1) · `@Fig-x` (capitalized) · `[-@fig-x]` (1) ·
`[Fig @fig-x]` (Fig 1) · group `[@fig-a; @fig-b]`.

Customization (`crossref:` in YAML): `fig-title`/`tbl-title` (caption prefix,
default Figure/Table), `title-delim` (default ":"), `fig-prefix`/`tbl-prefix`
(inline ref text), `labels`/`subref-labels` (arabic, roman, roman i, alpha x),
`chapters: true`, `lof-title`/`lot-title`/`lol-title` for PDF listing pages.
Locale overrides under `language:` (e.g. `crossref-fig-title: "Figura"`).

Caption text may itself reference OTHER elements (never itself) and even carry
computed inline values via the div syntax (`Caption: {python} len(x)` observations).

## 5. Reserved labels & shared gotchas

- Reserved prefixes (avoid for non-crossref ids): fig, tbl, lst, tip, nte, wrn,
  imp, cau, thm, lem, cor, prp, cnj, def, exm, exr, sol, rem, alg, eq, sec.
- Never label both an image and its enclosing fig div with the same id.
- Underscores in labels/ids break LaTeX/PDF; lowercase required.
- Divs/spans must be separated from surrounding blocks by blank lines.
- Code cells may appear inside list items/fenced divs/table cells but never inline
  in a paragraph or a heading.

## 6. ipynb-specific caption behavior (quarto-cli #4435)

- A markdown-cell image `![cap](path)` (or a notebook *attachment* image) DOES get
  its caption in **Quarto-rendered output** — but inside the Jupyter UI it shows
  as an image whose alt text is the caption; Jupyter has no figure-caption concept.
  Quarto devs consider this by-design (a JupyterLab extension was planned to bridge it).
- Rendering **to** `ipynb` format: file-referenced images become `attachment:` links;
  captions survive in Quarto output but not in the raw Jupyter notebook display.
- Prefer the figure-div pattern, or file-referenced (not attachment) images, for
  caption-critical notebooks.
- When syncing pairs with jupytext, `#|` options in the .qmd map to notebook cell
  metadata (keyed `quarto` options) — don't hand-edit both sides.
## 7. Footnotes

```markdown
Here is a footnote reference,[^1] and another.[^longnote]

[^1]: Here is the footnote.

[^longnote]: Here's one with multiple blocks.

    Subsequent paragraphs are indented to show that they
    belong to the previous footnote.

This paragraph won't be part of the note, because it isn't indented.
```

- Single-paragraph inline form: `Here is an inline note.^[Everything after the caret, no identifier needed.]`
- Identifiers may be numbers or words (`[^note]`); they are not displayed — footnotes are auto-numbered at render.
- IDs must be **unique within the document** (and across chapters in Quarto *books* rendered to PDF/DOCX/EPUB, since chapters are merged).
- Placement: HTML output puts footnote text at the bottom by default; set
  `reference-location: margin` in the post YAML to place it in the right margin —
  pairs naturally with the site's `cap-location: margin`. (Values: `default`, `margin`, `document`.)

## 8. Citations & bibliography

Enable per post — **`bibliography:` paths resolve relative to the post file, not
the project root**:
```yaml
---
title: "..."
bibliography: ../MyPapers2026.bib    # site .bib files live at the project root
# csl: ../nature.csl                 # optional style; default = Chicago author-date
---
```
- From `blog/<post>.qmd` use `../MyPapers2026.bib`. Leading-`/` "project-relative"
  metadata paths work for images/includes but are **unreliable for
  `bibliography:`/`csl:`** across output formats (quarto-cli #12553, open as of
  v1.9; typst is the only consistent one) — always use `../`-style
  document-relative paths here.
- Multiple files allowed: `bibliography: [../MyPapers.bib, refs.bib]`.
- Set it once per site instead by adding `bibliography:`/`csl:` at the top level
  of `_quarto.yml` (project metadata cascades into every post; per-post values
  override).
- CSL files already at the site root: `apa-cv.csl`, `cv.csl`, `nature.csl`,
  `nature-cv.csl` (`publications.qmd` uses `MyPapers2026.bib` + `apa-cv.csl`).

Citation syntax (citeproc switches on automatically when `bibliography:` is set):
| Markdown | Renders as |
|---|---|
| `@knuth1984 says …` | Knuth (1984) says … (in-text form) |
| `… [@knuth1984]` | … (Knuth 1984) |
| `As [-@knuth1984] says` | As (1984) says (author suppressed) |
| `[@knuth1984; @wickham2023]` | (Knuth 1984; Wickham et al. 2023) |
| `[@knuth1984, pp. 33–35]` | locator inside the parens |
| `[see @knuth1984, chap. 1; @wickham2023]` | prefix + suffix text around the cite |

- The rendered bibliography is emitted at the **end of the document**; add a
  `## References` heading as the last block of the post and it lands under it
  (standard Quarto tutorial pattern).
- Include uncited entries with `nocite:`:
  ```yaml
  nocite: |
    @knuth1984, @wickham2023
  ```
  (`'@*'` means ALL entries — avoid with a full personal bibliography file.)
- In HTML output citations are linked and get hover pop-ups by default
  (`link-citations`).
- Gotcha: don't name .bib keys with reserved crossref prefixes (`fig-…`, `tbl-…`,
  `sec-…`, `eq-…`) — a key like `@fig-1990` would be parsed as a
  cross-reference, not a citation.

## 9. Callouts

```markdown
::: {.callout-note}
Note that there are five types of callouts: `note`, `tip`, `warning`,
`important`, and `caution`.
:::
```
- Custom title: put a heading inside the div (`::: {.callout-tip}` + `## Pro Tip`).
- Collapsible: `::: {.callout-note collapse="true"}` (starts collapsed, click to open).
- Attributes: `appearance="default|simple|minimal"`, `icon=false` (HTML).
- Cross-referenceable: give an id with the matching prefix —
  `::: {#tip-example .callout-tip}` → referenced as `@tip-example`
  (id prefixes: `nte-` note, `tip-`, `wrn-` warning, `imp-` important, `cau-` caution).

## 10. Blog-post extras

- **Social/listing card**: `image:` in the post YAML is used both as the
  blog-listing thumbnail and as the `og:image` social card. Add `image-alt`;
  `image-width`/`image-height` default 1600×900 (Quarto adds them to the meta
  tags). `title-block-banner:` only controls the in-post banner, not the card.
- **Preserving links after renames/slug changes**: `aliases: ["/blog/old-slug.html"]`
  (site-URL-relative path ending in `.html`) — keeps old links working via redirect.
- **Pulling content from a notebook twin or other posts**:
  `{{< embed notebook.ipynb#fig-my-plot >}}` renders a labelled cell's output
  (caption included) inside another post; `{{< embed ... echo=true >}}` also shows
  the code. Cell matching order: cell `id` → `label` → tag. Source-notebook links
  are auto-added; control with `notebook-links: false`.
- **Code annotations** (pedagogical posts): end lines with `# <<` comments and set
  the document option `code-annotations: hover` (or `select`); renders numbered
  markers with the annotation text as tooltips. Set `code-annotations: none` to disable.
