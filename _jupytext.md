# Jupytext notes (post-migration reference)

Not rendered by Quarto (files starting with `_` are ignored by project renders).

## State of play (2026-10-08, commit 3ec02ae)

- **Blog and project sources are ipynb-only.** The jupytext pairing
  (`ipynb,qmd`, formats `qmd:quarto,ipynb`) was retired: all notebooks were
  unpaired, all `.qmd` twins in `blog/` and `projects/` deleted, and every
  jupytext metadata trace removed (nb metadata + front-matter stamps).
- **`_quarto.yml` renders `*.qmd`, `*.md` and `*.ipynb`**; notebooks carry their
  YAML front matter in the first cell and work exactly like qmd posts did.
- One format per post. If a future post is easier in qmd, just write a `.qmd`.
  Never keep both. (`migrate-to-ipynb.sh` at the repo root documents the
  migration; safe to delete.)
- **`.githooks/pre-commit` is now a no-op** — it used to jupytext-sync pairs at
  commit time.
- jupytext itself (1.19.5, conda env `jupyter`, plus the JupyterLab UI plugins)
  is still installed but unused. Uninstall freely:
  `pip uninstall jupytext` in the `jupyter` env (also `jupyterlab_jupytext`).

## Gotchas that still apply (these were jupytext-era but matter for Quarto-rendered notebooks)

- **Kernel for code cells**: pick **"Python 3 (main)"** so JupyterLab and Quarto
  agree on the interpreter (`~/miniforge3/envs/main/bin/python`).
- **Quarto only sees *static* kernelspecs** — nb_conda_kernels kernels
  (`conda-env-main-py`, …) are invisible to `quarto render --execute`.
  The static spec lives at `~/.local/share/jupyter/kernels/main`.
- Notebook kernelspec must be `name: main`. Kernel name `python3` is ambiguous
  (both envs have one) and silently breaks execution — this bit `pharos.ipynb`
  and `voice_chat.ipynb` on 2026-10-08; both were rewritten to `main`.
- **Saving in JupyterLab rewrites the kernelspec to the selected kernel.** If
  you select "Python [conda env:main]" the file gets `name: conda-env-main-py`,
  which Quarto cannot resolve → the whole site render fails). (Happened
  2026-09-14 with dawn.ipynb and blog/serobayes.qmd.) Always select
  **"Python 3 (main)"** for anything Quarto executes.

## If the envs change

```bash
# re-register main's kernel after recreating the main env:
~/miniforge3/envs/main/bin/python -m ipykernel install --user --name main \
  --display-name "Python 3 (main)"

# uninstall jupytext engine: pip uninstall jupytext (in the jupyter env)
```

The static kernelspec is a plain folder — safe to delete/recreate at
`~/.local/share/jupyter/kernels/main`.

## What `draft: true` means on this site (unchanged by the migration)

`draft-mode: unlinked` in `_quarto.yml`: drafts render with full content + a
Draft banner at their direct URL but stay out of the listing, search, sitemap
and navbar. `serobayes` (Jun-2020) and `Bayes_EvolveResequence` (Jan-2021) are
the only published posts (no `draft` field).

## Historical record

- Pairing setup, CLI sync commands and the auto-sync pre-commit hook that used
  to live here are documented in git history: see commits before 3ec02ae
  (e.g. `git show 0ddf263:...`/`5d5ca8e`) or `git log _jupytext.md`.
- Note: with `execute: freeze: auto` + `cache: true`, changed-notebook
  re-execution happens on the next render; unchanged docs reuse the freeze
  store / `.jupyter_cache`.