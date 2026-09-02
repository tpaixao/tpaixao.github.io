# tpaixao.github.io

Personal blog and site of Tiago Paixão, built with [Quarto](https://quarto.org) (journal Bootswatch theme).

## Structure

- `master` branch: Quarto source (`.qmd` files, `_quarto.yml`, assets)
- `gh-pages` branch: rendered HTML output only (build artifact, never edit by hand)
- `master` and `gh-pages` hold completely different content trees. Never push one onto the other, and never force-push (a 2026-08-31 accidental force-push wiped the rendered site; recovered from last good commit).

## Deploying

From the repo root:

```
quarto publish gh-pages
```

This renders the site, commits the output to `gh-pages`, and pushes in one step. Use `--no-prompt` for non-interactive runs. Posts with `draft: true` are skipped automatically. Code chunks use `eval: false`, so no R or Jupyter installation is needed to render.

Do not deploy by manually checking out `gh-pages` and copying files; `quarto publish` force-updates that branch by design, and any hand edits there will be lost.

## Notes

- `_post_render.py` copies `orcid/callback.html` into the rendered output after each render, because Quarto drops non-rendered source directories. It is self-locating: it derives paths from its own location and reads `output-dir` from `_quarto.yml`.
- The ORCID callback (`orcid/callback.html`) is domain-agnostic and parses `window.location.hash`, since implicit-flow tokens arrive in the URL fragment and are never sent to a server.
- `blog_references.bib` holds the bibliography used by blog posts (`csl: nature.csl`).