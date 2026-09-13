# Jupytext cheat sheet

Not rendered by Quarto (files starting with `_` are ignored by project renders).

## The setup (what exists where)

- **jupytext engine** 1.19.5 — installed in conda env `jupyter` (`~/miniforge3/envs/jupyter/bin/jupytext`)
- **JupyterLab integration** (`jupyterlab_jupytext` + `jupyterlab-jupytext` UI) — in the same env
- Paired files (formats `ipynb,qmd`):
  - `projects/`: `dawn`, `pharos`, `voice_chat`
  - `blog/`: all 8 posts (Bayes_EvolveResequence, dawn-2018-asset-protocol,
    decentralized-prehistory-2017-2019, health-data-pipeline,
    pharos-decentralized-preprints, scientific-commons-sovereignty,
    serobayes, voice-latency-engineering)
- The site renders **only** `*.qmd` / `*.md` (see `_quarto.yml`) — the `.ipynb` twins are ignored

## Pairing in JupyterLab (do once per notebook)

1. Open the `.ipynb` in JupyterLab
2. Menu **Jupytext → Pair with → Quarto Markdown** (or `Ctrl+Shift+C`, type "pair quarto")
   - writes `"jupytext": {"formats": "ipynb,qmd"}` into the notebook metadata
3. `Ctrl+S` → both `.ipynb` and `.qmd` are written, always in sync

## CLI (bulk pairing + edits made outside JupyterLab)

```bash
J=~/miniforge3/envs/jupyter/bin

# pair once (per notebook):
$J/jupytext --set-formats ipynb,qmd projects/dawn.ipynb

# reconcile after external edits (newest file's mtime wins):
$J/jupytext --sync projects/*.ipynb
```

`--sync` picks whichever side has the newer timestamp as the source.
If both changed (rare), it errors instead of guessing — resolve manually.

## Gotchas

- **First paired save rewrites the `.qmd`**: YAML gets re-serialized (`title: DAWN` unquoted,
  `categories` as list), a `jupyter: jupytext: ...` stamp block is added, blank lines
  normalized. ~27 lines of cosmetic diff on dawn.qmd, zero content change.
  Review the git diff once, commit, stable afterwards.
- **Kernel for code cells**: pick **"Python 3 (main)"** so JupyterLab and Quarto
  agree on the interpreter (`~/miniforge3/envs/main/bin/python`).
- **Quarto only sees *static* kernelspecs** — nb_conda_kernels kernels
  (`conda-env-main-py`, …) are invisible to `quarto render --execute`.
  The static spec lives at `~/.local/share/jupyter/kernels/main`.
- `.qmd` execution needs `jupyter: main` in the front matter; `.ipynb` needs
  kernelspec name `main`. Kernel name `python3` is ambiguous (both envs have one).
- Quarto 1.10.18 rejects python paths in `jupyter:` — kernel names only.
- **Saving in JupyterLab rewrites the kernelspec to the selected kernel.** If you
  select "Python [conda env:main]" the file gets `name: conda-env-main-py`, which
  Quarto cannot resolve → the whole site render fails. (This happened on
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