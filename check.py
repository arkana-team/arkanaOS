import os
import re

mk_dir = "arkanas"
for filename in os.listdir(mk_dir):
    if not filename.endswith(".mk"): continue
    path = os.path.join(mk_dir, filename)
    with open(path, "r") as f:
        content = f.read()

    # Find malformed MAKE commands like `$(MAKE) $(MAKE)` or missing `&&`
    for i, line in enumerate(content.split('\n'), 1):
        if re.search(r'\$\(MAKE\)\s+\$\(MAKE\)', line):
            print(f"{filename}:{i} Malformed MAKE: {line.strip()}")
        # Check for target missing headers properly
    
    prereqs = re.findall(r'(\.[\w\-]+-done)', content)
    targets = re.findall(r'^(\.[\w\-]+-done):', content, re.MULTILINE)
    missing = set(prereqs) - set(targets)
    missing = {m for m in missing if not m.startswith('.$( ')}
    if missing:
        print(f"{filename}: Missing targets: {missing}")

