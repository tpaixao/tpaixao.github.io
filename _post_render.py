import shutil
import os
import sys

# Quarto post-render script: copies the Pharos ORCID callback page into the
# rendered output so it survives every site re-render (Quarto would otherwise
# drop non-rendered source dirs from the output).
#
# Self-locating: derives the project root from this script's own path and reads
# output-dir from _quarto.yml, so it does not depend on Quarto's cwd or argv.

script_dir = os.path.dirname(os.path.abspath(__file__))
src = os.path.join(script_dir, "orcid", "callback.html")

# Read output-dir from _quarto.yml (default: _site)
output_dir = "_site"
try:
    with open(os.path.join(script_dir, "_quarto.yml")) as f:
        for line in f:
            if line.strip().startswith("output-dir:"):
                output_dir = line.split(":", 1)[1].strip().strip('"').strip("'")
                break
except OSError:
    pass

out_root = os.path.join(script_dir, output_dir)

if os.path.exists(src):
    dst_dir = os.path.join(out_root, "orcid")
    os.makedirs(dst_dir, exist_ok=True)
    shutil.copy(src, os.path.join(dst_dir, "callback.html"))