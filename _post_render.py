import shutil
import os
import sys

# Quarto post-render script: runs with args = rendered file paths, cwd = project root
# Copies the Pharos ORCID callback page into the rendered output so it survives
# every site re-render (Quarto would otherwise drop non-rendered dirs).
args = sys.argv[1:]
if not args:
    sys.exit(0)

out_dir = os.path.dirname(args[0])
src = os.path.join(os.path.dirname(out_dir.rstrip("/")) if False else os.getcwd(), "orcid", "callback.html")
dst_dir = os.path.join(out_dir, "orcid")
os.makedirs(dst_dir, exist_ok=True)
shutil.copy(src, os.path.join(dst_dir, "callback.html"))
