import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
FETCH_SCRIPT = REPO_ROOT / "scripts/download-gnu-source.sh"
GNU_MAKEFILES = (
    REPO_ROOT / "arkanas/01_base.mk",
    REPO_ROOT / "arkanas/02_ext.mk",
    REPO_ROOT / "arkanas/04_toolchain.mk",
    REPO_ROOT / "arkanas/07_iso.mk",
)
MIRROR_PREFIX = "https://mirrors.ocf.berkeley.edu/gnu/"
ORIGIN_PREFIX = "https://ftp.gnu.org/gnu/"


class GnuSourceDownloadTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="arkana-gnu-fetch-")
        self.root = Path(self.temporary.name)
        self.bin_dir = self.root / "bin"
        self.bin_dir.mkdir()
        self.calls_file = self.root / "curl-calls.jsonl"
        self.output = self.root / "source.tar.gz"
        fake_curl = self.bin_dir / "curl"
        fake_curl.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib, sys\n"
            "args = sys.argv[1:]\n"
            "path = pathlib.Path(args[args.index('-o') + 1])\n"
            "url = args[-1]\n"
            "with open(os.environ['CURL_CALLS'], 'a', encoding='utf-8') as log:\n"
            "    log.write(json.dumps(args) + '\\n')\n"
            "failed = json.loads(os.environ.get('CURL_FAIL_URLS', '[]'))\n"
            "path.write_bytes(b'partial' if url in failed else url.encode())\n"
            "raise SystemExit(22 if url in failed else 0)\n",
            encoding="utf-8",
        )
        fake_curl.chmod(0o755)
        self.environment = os.environ.copy()
        self.environment.update(
            {
                "PATH": f"{self.bin_dir}{os.pathsep}{os.environ['PATH']}",
                "CURL_CALLS": str(self.calls_file),
            }
        )

    def tearDown(self):
        self.temporary.cleanup()

    def run_fetch(self, url, failed_urls=()):
        self.environment["CURL_FAIL_URLS"] = json.dumps(list(failed_urls))
        return subprocess.run(
            [str(FETCH_SCRIPT), str(self.output), url],
            check=False,
            capture_output=True,
            env=self.environment,
            text=True,
            timeout=10,
        )

    def recorded_calls(self):
        if not self.calls_file.exists():
            return []
        return [
            json.loads(line)
            for line in self.calls_file.read_text(encoding="utf-8").splitlines()
        ]

    def test_successful_mirror_download_does_not_use_fallback(self):
        url = f"{MIRROR_PREFIX}mpfr/mpfr-4.2.2.tar.gz"

        result = self.run_fetch(url)

        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.recorded_calls()
        self.assertEqual([call[-1] for call in calls], [url])
        self.assertIn("--retry-all-errors", calls[0])
        self.assertEqual(calls[0][calls[0].index("--retry") + 1], "3")
        self.assertEqual(calls[0][calls[0].index("--max-time") + 1], "600")
        self.assertEqual(self.output.read_bytes(), url.encode())
        self.assertEqual(self.output.stat().st_mode & 0o777, 0o644)

    def test_transfer_limit_can_be_overridden(self):
        url = f"{MIRROR_PREFIX}mpfr/mpfr-4.2.2.tar.gz"
        self.environment["GNU_DOWNLOAD_MAX_TIME"] = "1800"

        result = self.run_fetch(url)

        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.recorded_calls()
        self.assertEqual(calls[0][calls[0].index("--max-time") + 1], "1800")

    def test_mirror_failure_retries_matching_official_gnu_path(self):
        url = f"{MIRROR_PREFIX}mpfr/mpfr-4.2.2.tar.gz"
        fallback = f"{ORIGIN_PREFIX}mpfr/mpfr-4.2.2.tar.gz"

        result = self.run_fetch(url, failed_urls=(url,))

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            [call[-1] for call in self.recorded_calls()], [url, fallback]
        )
        self.assertEqual(self.output.read_bytes(), fallback.encode())
        self.assertIn(fallback, result.stderr)
        self.assertEqual(list(self.root.glob("source.tar.gz.download.*")), [])

    def test_non_gnu_failure_does_not_rewrite_or_retry_url(self):
        url = "https://example.invalid/archive.tar.gz"

        result = self.run_fetch(url, failed_urls=(url,))

        self.assertEqual(result.returncode, 22)
        self.assertEqual([call[-1] for call in self.recorded_calls()], [url])
        self.assertFalse(self.output.exists())

    def test_failed_fallback_preserves_existing_archive_and_cleans_partial_file(self):
        url = f"{MIRROR_PREFIX}mpfr/mpfr-4.2.2.tar.gz"
        fallback = f"{ORIGIN_PREFIX}mpfr/mpfr-4.2.2.tar.gz"
        self.output.write_bytes(b"existing archive")

        result = self.run_fetch(url, failed_urls=(url, fallback))

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(
            [call[-1] for call in self.recorded_calls()], [url, fallback]
        )
        self.assertEqual(self.output.read_bytes(), b"existing archive")
        self.assertEqual(list(self.root.glob("source.tar.gz.download.*")), [])

    def test_all_berkeley_gnu_mirror_recipes_use_the_fallback_helper(self):
        mirror_variables = {}
        for makefile in GNU_MAKEFILES:
            for line in makefile.read_text(encoding="utf-8").splitlines():
                if MIRROR_PREFIX not in line:
                    continue
                name, separator, _value = line.partition("=")
                if separator and name.strip().endswith("_URL"):
                    mirror_variables[name.strip()] = makefile

        self.assertGreater(len(mirror_variables), 0)
        for variable, makefile in mirror_variables.items():
            recipe_uses = [
                line
                for line in makefile.read_text(encoding="utf-8").splitlines()
                if f"$({variable})" in line
            ]
            self.assertTrue(recipe_uses, f"{variable} has no download recipe")
            self.assertTrue(
                all("scripts/download-gnu-source.sh" in line for line in recipe_uses),
                f"{variable} bypasses the retry/fallback helper: {recipe_uses}",
            )


if __name__ == "__main__":
    unittest.main()
