import os
import re

mk_dir = "arkanas"
for filename in os.listdir(mk_dir):
    if not filename.endswith(".mk"): continue
    path = os.path.join(mk_dir, filename)
    with open(path, "r") as f:
        content = f.read()

    for i, line in enumerate(content.split('\n'), 1):
        if line.strip().startswith('#'): continue
        # simple check for unbalanced quotes in a line
        if line.count('"') % 2 != 0:
            print(f"{filename}:{i} Unbalanced double quotes: {line}")
        if line.count("'") % 2 != 0:
            print(f"{filename}:{i} Unbalanced single quotes: {line}")
