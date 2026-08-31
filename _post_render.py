import shutil
import os
import sys

# Quarto post-render script: copies the Pharos ORCID callback page into the
# rendered output so it survives every site re-render (Quarto would otherwise
# drop non-rendered source dirs from the output).
args = sys.argv[1:]
if not args:
    sys.exit(0)

# First arg is always a rendered file inside the output dir, e.g. _site/index.html
first = args[0]
# Strip the filename, and any subdirectory, to get the output root
out_root = os.path.dirname(first)
while True:
    parent = os.path.dirname(out_root)
    if parent == out_root or os.path.basename(out_root) in ("", "/"):
        break
    # Stop at the directory that contains the site index or looks like the root
    if os.path.exists(os.path.join(out_root, "index.html")) or out_root.split(os.sep)[-1] in ("_site", "docs", "html", "public", "_book"):
        break
    out_root = parent

src = os.path.join(os.getcwd(), "orcid", "callback.html")
dst_dir = os.path.join(out_root, "orcid")
os.makedirs(dst_dir, exist_ok=True)
shutil.copy(src, os.path.join(dst_dir, "callback.html"))