import os
import re

mk_dir = "arkanas"
if not os.path.isdir(mk_dir):
    print(f"Directory {mk_dir} not found")
    exit(1)

for filename in os.listdir(mk_dir):
    if not filename.endswith(".mk"):
        continue
    filepath = os.path.join(mk_dir, filename)
    with open(filepath, "r") as f:
        content = f.read()
    
    # Find all prerequisites ending in -done
    prereqs = re.findall(r'(\.[\w\-]+-done)', content)
    prereqs = set(prereqs)
    
    # Find all target definitions
    targets = set(re.findall(r'^(\.[\w\-]+-done):', content, re.MULTILINE))
    
    missing = prereqs - targets
    # Filter out variables that might be matched
    missing = {m for m in missing if not m.startswith('.$( ')}
    
    if missing:
        print(f"File {filename} is missing target headers for: {missing}")
