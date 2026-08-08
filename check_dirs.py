import os
import re

mk_dir = "arkanas"
for filename in os.listdir(mk_dir):
    if not filename.endswith(".mk"): continue
    path = os.path.join(mk_dir, filename)
    with open(path, "r") as f:
        content = f.read()

    # Look for patterns like tar xf ... \n cd ... 
    # to see if the directory cd'd into is defined correctly.
    for i, line in enumerate(content.split('\n'), 1):
        if 'cd $(' in line and 'PATH' not in line and '&&' in line:
            # We can't statically analyze all of them easily but we can see if there are any obvious typos
            pass
