import os
import re

mk_dir = "arkanas"
for filename in os.listdir(mk_dir):
    if not filename.endswith(".mk"): continue
    path = os.path.join(mk_dir, filename)
    with open(path, "r") as f:
        content = f.read()

    # Find used variables like $(VAR_NAME)
    used_vars = set(re.findall(r'\$\(([A-Z0-9_]+)\)', content))
    # Find defined variables like VAR_NAME=... or VAR_NAME = ... or VAR_NAME := ...
    defined_vars = set(re.findall(r'^([A-Z0-9_]+)\s*[:]?=', content, re.MULTILINE))
    
    # Common variables defined in environment or other files
    common = {"MAKE", "THREADS", "SRC_PATH", "STAGING_PATH", "OUTPUT_PATH", "ROOTFS_PATH"}
    
    missing_vars = used_vars - defined_vars - common
    if missing_vars:
        print(f"{filename}: Might be missing variable definitions: {missing_vars}")

