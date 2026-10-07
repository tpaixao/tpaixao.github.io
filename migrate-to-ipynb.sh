#!/usr/bin/env bash
# migrate-to-ipynb.sh — one-time migration to "ipynb as single source of truth"
#
# 1. jupytext --sync each pair (safety: newest-edit side wins, per your cheat sheet)
# 2. Unpair each ipynb (strip jupytext pairing metadata)
# 3. qmd-only posts -> convert with `quarto convert`, keep the ipynb, delete the qmd
# 4. Delete the qmd twin of every already-paired post (ipynb is now canonical)
# 5. Report what needs manual follow-up (hook, _jupytext.md, site pages)
#
# Usage:
#   ./migrate-to-ipynb.sh --dry-run   # print plan only (default)
#   ./migrate-to-ipynb.sh --apply     # actually do it
#
# Site pages (index/about/cv/blog.qmd/publications) are NOT touched — they stay qmd.
#
DRY_RUN=true
[ "$1" = "--apply" ] && DRY_RUN=false

JUPYTEXT=~/miniforge3/envs/jupyter/bin/jupytext

run() {
  echo "  \$ $*"
  if [ "$DRY_RUN" = false ]; then "$@" || echo "  !! FAILED: $*"; fi
}

# Posts/projects = paired docs. Site pages are excluded.
POSTS=$(ls blog/*.ipynb projects/*.ipynb 2>/dev/null)
PAGES="index.qmd about.qmd cv.qmd blog.qmd publications.qmd"

echo "=== 0. Unsynced / state checks ======================================"
for nb in $POSTS; do
  qmd="${nb%.ipynb}.qmd"
  if [ -f "$qmd" ]; then
    # compare content-sync state via mtime (jupytext's own rule of thumb)
    if [ "$qmd" -nt "$nb" ]; then
      echo "  [drift?] $qmd is NEWER than $nb — --sync in step 1 will take the qmd side"
    elif [ "$nb" -nt "$qmd" ]; then
      echo "  [drift?] $nb is NEWER than $qmd — --sync in step 1 will take the ipynb side"
    fi
  fi
done
echo

echo "=== 1. Final sync of every pair ====================================="
for nb in $POSTS; do
  [ -f "${nb%.ipynb}.qmd" ] && run "$JUPYTEXT" --sync "$nb"
done
echo

echo "=== 2. Unpair ipynbs (remove jupytext pairing metadata) ============="
for nb in $POSTS; do
  if [ -f "${nb%.ipynb}.qmd" ]; then
    # --set-formats with a single format removes the pair definition
    run "$JUPYTEXT" --set-formats ipynb "$nb"
  fi
done
echo

echo "=== 3. Convert qmd-only posts ======================================="
for q in blog/*.qmd projects/*.qmd; do
  base="${q%.qmd}"
  keep=false
  for p in ${PAGES[@]}; do [ "$q" = "$p" ] && keep=true; done
  if [ "$keep" = true ]; then
    echo "  [skip site page] $q (stays qmd)"
  elif [ ! -f "$base.ipynb" ]; then
    run quarto convert "$q"      # writes $base.ipynb
    run git rm -q "$q"
  else
    echo "  [paired -> delete twin] $q (ipynb already authoritative)"
    run git rm -q "$q"
  fi
done
echo

echo "=== 4. Manual follow-ups (NOT automated) ============================"
cat <<'EOF'
  a. Disable/replace .githooks/pre-commit — it jupytext-syncs pairs that will
     no longer exist. Either `git config --unset core.hooksPath` or edit the hook.
  b. Update _jupytext.md — pairing instructions no longer apply.
  c. If any pre-commit-synced twin was drifted, review git diff before committing
     (the sync in step 1 already reconciled by mtime, but eyeball it).
  d. Sanity render:  quarto render blog/ --to html   (freeze means most won't re-execute)
EOF
echo

if [ "$DRY_RUN" = true ]; then
  echo "=== DRY RUN — nothing was changed. Run with --apply to execute. ==="
fi