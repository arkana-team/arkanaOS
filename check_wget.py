import os

mk_dir = "arkanas"
for filename in os.listdir(mk_dir):
    if not filename.endswith(".mk"): continue
    path = os.path.join(mk_dir, filename)
    with open(path, "r") as f:
        content = f.read()

    for i, line in enumerate(content.split('\n'), 1):
        if 'wget ' in line and '-O' not in line:
            print(f"{filename}:{i} wget without -O: {line.strip()}")
