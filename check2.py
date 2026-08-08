import os
import re

mk_dir = "arkanas"
for filename in os.listdir(mk_dir):
    if not filename.endswith(".mk"): continue
    path = os.path.join(mk_dir, filename)
    with open(path, "r") as f:
        content = f.read()

    prereqs = re.findall(r'(\.[\w\-]+-obtained)', content)
    targets = re.findall(r'^(\.[\w\-]+-obtained):', content, re.MULTILINE)
    missing = set(prereqs) - set(targets)
    missing = {m for m in missing if not m.startswith('.$( ')}
    if missing:
        print(f"{filename}: Missing targets: {missing}")

