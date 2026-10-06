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

## 11. Embedded images in notebooks (attachments vs outputs)

Two distinct cases (tested empirically with jupytext 1.19.5, 2026-10-05):

- **Cell outputs (`image/png` in display_data/execute_result): nothing to save.**
  The `.qmd` twin carries the CODE; the Quarto render re-executes it and
  regenerates the figure into its own figures dir. Outputs embedded in the
  `.ipynb` are only consumed when rendering the `.ipynb` directly (Quarto
  auto-extracts them at render time). This is the live-figure design:
  "figures regenerate in ~20s".
- **Markdown-cell attachments (`![cap](attachment:x.png)` + base64 in the
  cell's `attachments` field): YES, they must be extracted.** Jupytext carries
  the `attachment:` link verbatim into the `.qmd` and does NOT extract the
  image; plain Quarto markdown cannot resolve `attachment:` URLs, so the twin
  renders a broken image. Fix: save the attachment to `blog/images/`, rewrite
  the markdown link to a normal relative path, re-sync, and (optionally) drop
  the now-redundant base64 attachment from the notebook to slim it.

Recipe:
```bash
python3 -c "import json,base64,pathlib; nb=json.load(open('post.ipynb')); \
[pathlib.Path('images/'+n).write_bytes(base64.b64decode(list(m.values())[0])) \
 for c in nb['cells'] for n,m in c.get('attachments',{}).items()]"
```
Then rewrite `attachment:<name>` → `images/<name>` in the .qmd and sync.

Rule of thumb: **paste-screenshots in notebooks are attachments (need saving);
matplotlib/plot output is not (regenerates).** As of 2026-10-05 none of the
notebook-only posts contain attachments — all their images are outputs.

## 12. Rendering WITHOUT re-executing the code (verified 2026-10-05)

A `.qmd` twin carries code only, never outputs. Three verified ways to get
figures without re-executing:

1. **`freeze` (recommended, zero extra deps).** `execute: freeze: auto`. Applied
   SITE-WIDE in `_quarto.yml` (2026-10-05): `execute:\n  freeze: auto` at top
   level. Any render that executes records outputs in
   `.quarto/project-cache/` (project root; already gitignored via `/.quarto/`).
   Subsequent renders serve the frozen outputs: **no kernel starts at all**
   (DM-simulation post: 6.6s vs 27.6s cold). `auto` re-executes when the file's
   content changes (or on first render); `true` never re-executes in site
   renders. Sentinel test: rendered timestamp identical across replays.
2. **`cache: true` (jupyter-cache layer).** Requires the `jupyter-cache` pip
   package in the jupyter env (installed 2026-10-05). First render executes and
   seeds `blog/.jupyter_cache/`; later renders log "(Notebook read from
   cache)" (~10-11 s; no re-execution). **Applied site-wide 2026-10-07**
   alongside `freeze: auto` (`execute: cache: true` in `_quarto.yml`).
   Sentinel-verified (DM post, temp non-draft copy): cold render 24.5 s
   (executes, seeds cache); prose-only edit → cache replay 10.9 s, sentinel
   timestamp UNCHANGED (no re-execution); code-cell change → re-execution
   23.2 s, timestamp updated. Grain is the NOTEBOOK, not the cell: any
   code-cell change re-runs the whole notebook. Full site render with
   freeze+cache: exit 0, 16 s, zero kernel starts (freeze replayed all; cache
   absorbs prose-only changes when a file does re-render). Net effect:
   prose editing never re-executes code. `--cache-refresh` / `cache-refresh`
   forces re-seed. Gitignored.
3. **Render the `.ipynb` directly.** Quarto does NOT execute ipynbs by default
   and uses the embedded saved outputs (figures auto-extracted to
   `*_files/figure-html/`). For the website to render notebook-only posts,
   extend `project.render` in `_quarto.yml` with `*.ipynb` (currently
   `*.qmd`/`*.md` only).

Verification protocol (sentinel): append a cell `print('SENTINEL', time.time())`,
render twice, compare the rendered value: equal = replay, changed = re-execution.

Confounds that fooled timing measurements: the Jupyter **kernel daemon** keeps
a warm kernel ~300s (re-execution on warm kernel looks deceptively fast);
`draft: true` posts render to a **90-byte stub** (no figures in the HTML) but
their code STILL EXECUTES during renders (verified 2026-10-05: seed cache was
populated by a draft render; missing deps abort full site renders) — so audit
visibility via a temp copy, and remember drafts burn compute each site render
until their freeze entries exist.

**Standalone-render trap (found 2026-10-07):** explicitly rendering a file
EXCLUDED from `project.render` (e.g. an underscore-prefixed `_scratch.qmd`)
runs it as a STANDALONE document — no project execute options (no freeze,
no cache) and the output lands NEXT TO the source, not in `_site/`. Sentinel
and cache tests must use a normally named temp copy in `blog/` (delete after).

**Prose-editing loop (verified 2026-10-07):** `mamba run -n jupyter quarto
render blog/<post>.qmd` — first render executes and seeds the cache; every
subsequent prose-only save replays from cache (no re-execution). `--execute`
forces fresh outputs. `quarto preview` hot-reloads on save with the same
replay semantics, so it is safe to keep open while writing.

## 13. Execution environment control (conda) — verified 2026-10-05

Model: Quarto does not execute "in a conda env"; it executes in a **Jupyter
kernel**, whose `argv[0]` is the env's python. On this machine (Quarto
1.10.18) `jupyter:` values are **kernel names only** — no interpreter paths,
no `python-path`; `QUARTO_JUPYTER` also takes kernel names.

Verified state (2026-10-05):
- Kernels quarto sees: `python3`, `main` (check with `quarto check jupyter`,
  full list: `mamba run -n jupyter jupyter kernelspec list`).
- Kernel `main` = `~/.local/share/jupyter/kernels/main/kernel.json` →
  `/home/tiago/miniforge3/envs/main/bin/python` ("Python 3 (main)").
- Two-level dispatch: `mamba run -n jupyter quarto render ...` only supplies
  TOOLING (quarto, jupytext, nbformat, jupyter-cache — none live in `main`);
  the kernel chooses the ANALYSIS env. The outer env never runs post code.

Control points, in order of preference:
1. **Per post**: `jupyter: main` (shorthand) or the full
   `jupyter: {jupytext: ..., kernelspec: {name: main}}` block (what the
   skeleton carries; must match its `.ipynb` twin's metadata).
2. **Whole site**: `jupyter: main` at top level of `_quarto.yml`.
3. **CLI**: `QUARTO_JUPYTER=main quarto render ...` (env var).

Registering a NEW analysis env so quarto can use it:
```bash
mamba install -n <env> ipykernel          # kernel machinery inside the env
~/miniforge3/envs/<env>/bin/python -m ipykernel install --user --name <env>
jupyter: <env>                            # in post or site YAML
```
Install the kernelspec to the USER dir (--user): kernelspecs placed inside a
conda env prefix get re-labeled by nb_conda_kernels by LOCATION (trap hit
2026-09-13); user-dir specs pass through as-is and quarto finds them.

Traps (all previously hit):
- `conda-env-<env>-py` kernels (nb_conda_kernels, JupyterLab UI picks) are
  invisible to quarto — never let a post carry one.
- `python3` is ambiguous (both `jupyter` and `main` envs would answer); prefer
  named kernelspecs.
- JupyterLab SAVE rewrites the notebook kernelspec to the currently selected
  kernel — after editing in JupyterLab, verify the kernelspec says `main`.
- Sanity check inside a post: a scratch cell with
  `import sys; print(sys.executable)` shows who actually executed.

## 14. Making the site live (deploy) — per Tiago, 2026-10-05

**The deploy step is `quarto publish`** (easiest way to make the blog live; it
supersedes manual gh-pages branch surgery). For this site:

```bash
mamba run -n jupyter quarto publish gh-pages        # or plain `quarto publish` (interactive provider pick)
```

Verified interface (Quarto 1.10.18): providers `gh-pages`, `netlify`,
`quarto-pub`, ...; options `--no-render` (skip the render — useful right after
a site render with freeze), `--no-prompt`, `--no-browser`, `--id`, `--token`.
`gh-pages` = renders (unless `--no-render`), then builds the site onto the
gh-pages branch and pushes it. The root `CNAME` (custom domain
tiagopaixao.com) is carried into the deploy automatically.

Preconditions and standing rule:
- Working tree must be **clean and pushed** on its branch (currently true:
  blogify-methods-projects @ 2581495 pushed, gh-pages untouched).
- **Deploy = gh-pages update = site goes live. This step ONLY runs when Tiago
  explicitly asks to make posts live** (his rule from 2026-10-05; pushes to
  working branches never deploy). All listing-relevant state lives on the
  working branch until then.
- Draft posts render as stubs and are excluded from the listing even on a
  deploy; flipping `draft: false` + publishing is how a new post goes out.
