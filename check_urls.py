import os
import re
import urllib.request
import urllib.error
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

mk_dir = "arkanas"
urls = []
for filename in os.listdir(mk_dir):
    if not filename.endswith(".mk"): continue
    path = os.path.join(mk_dir, filename)
    with open(path, "r") as f:
        content = f.read()

    # Find variables like VAR_URL=...
    found_urls = re.findall(r'^([A-Z0-9_]+_URL)\s*[:]?=\s*(http[^\s]+)', content, re.MULTILINE)
    urls.extend([(filename, var, url) for var, url in found_urls])

print(f"Checking {len(urls)} URLs...")
failed = []
import concurrent.futures

def check_url(item):
    filename, var, url = item
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, context=ctx, timeout=5) as response:
            if response.status not in (200, 301, 302):
                return f"{filename}: {var} {url} returned {response.status}"
    except urllib.error.HTTPError as e:
        if e.code != 403: # GitHub / SourceForge sometimes 403 on HEAD or python User-Agent
            return f"{filename}: {var} {url} HTTP Error {e.code}"
    except Exception as e:
        return f"{filename}: {var} {url} Error {e}"
    return None

with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
    results = executor.map(check_url, urls)
    for r in results:
        if r:
            print(r)
