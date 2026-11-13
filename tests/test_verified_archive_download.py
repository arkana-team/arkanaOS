"""Test integrity-checked archive downloads and firmware source pinning."""

from __future__ import annotations

import hashlib
import io
import json
import os
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DOWNLOAD_SCRIPT = REPO_ROOT / "scripts/download-verified-archive.sh"
ISO_RECIPE = REPO_ROOT / "arkanas/07_iso.mk"
PAYLOAD = b"pinned source archive fixture\n"
PRIMARY_URL = "https://cdn.example.invalid/source.tar.xz"
FALLBACK_URL = "https://mirror.example.invalid/source.tar.xz"
EXPECTED_SHA256 = hashlib.sha256(PAYLOAD).hexdigest()


class VerifiedArchiveDownloadTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix="arkana-verified-archive-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.bin_dir = self.root / "bin"
        self.bin_dir.mkdir()
        self.output = self.root / "source.tar.xz"
        self.calls_file = self.root / "curl-calls.jsonl"
        self.payload_file = self.root / "payload"
        self.payload_file.write_bytes(PAYLOAD)
        fake_curl = self.bin_dir / "curl"
        fake_curl.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib, sys\n"
            "args = sys.argv[1:]\n"
            "output = pathlib.Path(args[args.index('-o') + 1])\n"
            "url = args[-1]\n"
            "with open(os.environ['CURL_CALLS'], 'a', encoding='utf-8') as log:\n"
            "    log.write(json.dumps(args) + '\\n')\n"
            "failed = json.loads(os.environ.get('CURL_FAIL_URLS', '[]'))\n"
            "corrupt = json.loads(os.environ.get('CURL_CORRUPT_URLS', '[]'))\n"
            "if url in failed:\n"
            "    output.write_bytes(b'partial transfer')\n"
            "    raise SystemExit(22)\n"
            "if url in corrupt:\n"
            "    output.write_bytes(b'corrupt archive')\n"
            "else:\n"
            "    output.write_bytes(pathlib.Path(os.environ['CURL_PAYLOAD']).read_bytes())\n"
            "raise SystemExit(0)\n",
            encoding="utf-8",
        )
        fake_curl.chmod(0o755)
        self.environment = os.environ.copy()
        self.environment.update(
            {
                "PATH": f"{self.bin_dir}{os.pathsep}{os.environ['PATH']}",
                "CURL_CALLS": str(self.calls_file),
                "CURL_PAYLOAD": str(self.payload_file),
                "CURL_FAIL_URLS": "[]",
                "CURL_CORRUPT_URLS": "[]",
            }
        )
        self.environment.pop("ARKANA_SOURCE_DOWNLOAD_MAX_TIME", None)

    def run_fetch(
        self, expected_sha256: str = EXPECTED_SHA256
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [
                str(DOWNLOAD_SCRIPT),
                str(self.output),
                expected_sha256,
                PRIMARY_URL,
                FALLBACK_URL,
            ],
            check=False,
            capture_output=True,
            env=self.environment,
            text=True,
            timeout=10,
        )

    def recorded_calls(self) -> list[list[str]]:
        if not self.calls_file.exists():
            return []
        return [
            json.loads(line)
            for line in self.calls_file.read_text(encoding="utf-8").splitlines()
        ]

    def test_primary_archive_is_verified_and_cached(self) -> None:
        result = self.run_fetch()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([call[-1] for call in self.recorded_calls()], [PRIMARY_URL])
        self.assertEqual(self.output.read_bytes(), PAYLOAD)
        self.assertEqual(self.output.stat().st_mode & 0o777, 0o644)
        arguments = self.recorded_calls()[0]
        self.assertIn("--retry-all-errors", arguments)
        self.assertEqual(arguments[arguments.index("--max-time") + 1], "1800")

        result = self.run_fetch()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.recorded_calls()), 1)

    def test_download_timeout_can_be_configured(self) -> None:
        self.environment["ARKANA_SOURCE_DOWNLOAD_MAX_TIME"] = "2400"

        result = self.run_fetch()

        self.assertEqual(result.returncode, 0, result.stderr)
        arguments = self.recorded_calls()[0]
        self.assertEqual(arguments[arguments.index("--max-time") + 1], "2400")

    def test_primary_transfer_failure_uses_verified_fallback(self) -> None:
        self.environment["CURL_FAIL_URLS"] = json.dumps([PRIMARY_URL])

        result = self.run_fetch()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            [call[-1] for call in self.recorded_calls()], [PRIMARY_URL, FALLBACK_URL]
        )
        self.assertEqual(self.output.read_bytes(), PAYLOAD)
        self.assertEqual(list(self.root.glob("source.tar.xz.download.*")), [])

    def test_primary_checksum_failure_uses_verified_fallback(self) -> None:
        self.environment["CURL_CORRUPT_URLS"] = json.dumps([PRIMARY_URL])

        result = self.run_fetch()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("SHA-256 verification failed", result.stderr)
        self.assertEqual(
            [call[-1] for call in self.recorded_calls()], [PRIMARY_URL, FALLBACK_URL]
        )
        self.assertEqual(self.output.read_bytes(), PAYLOAD)

    def test_two_failed_sources_preserve_existing_output_and_remove_partials(self) -> None:
        self.output.write_bytes(b"existing archive")
        self.environment["CURL_FAIL_URLS"] = json.dumps([PRIMARY_URL, FALLBACK_URL])

        result = self.run_fetch()

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.output.read_bytes(), b"existing archive")
        self.assertEqual(
            [call[-1] for call in self.recorded_calls()], [PRIMARY_URL, FALLBACK_URL]
        )
        self.assertEqual(list(self.root.glob("source.tar.xz.download.*")), [])

    def test_invalid_existing_archive_is_replaced_only_after_verification(self) -> None:
        self.output.write_bytes(b"stale archive")
        self.environment["CURL_FAIL_URLS"] = json.dumps([PRIMARY_URL, FALLBACK_URL])

        failed = self.run_fetch()

        self.assertNotEqual(failed.returncode, 0)
        self.assertEqual(self.output.read_bytes(), b"stale archive")

        self.environment["CURL_FAIL_URLS"] = "[]"
        succeeded = self.run_fetch()

        self.assertEqual(succeeded.returncode, 0, succeeded.stderr)
        self.assertEqual(self.output.read_bytes(), PAYLOAD)

    def test_symlink_and_directory_outputs_are_rejected(self) -> None:
        target = self.root / "target"
        target.write_bytes(b"leave untouched")
        self.output.symlink_to(target)

        result = self.run_fetch()

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(target.read_bytes(), b"leave untouched")
        self.assertEqual(self.recorded_calls(), [])

        self.output.unlink()
        self.output.mkdir()
        result = self.run_fetch()

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.recorded_calls(), [])

    def test_invalid_hash_and_unbounded_timeout_are_rejected_before_download(self) -> None:
        result = self.run_fetch("not-a-sha256")

        self.assertEqual(result.returncode, 2)
        self.assertEqual(self.recorded_calls(), [])

        self.environment["ARKANA_SOURCE_DOWNLOAD_MAX_TIME"] = "0"
        result = self.run_fetch()

        self.assertEqual(result.returncode, 2)
        self.assertEqual(self.recorded_calls(), [])

    def test_firmware_recipes_use_pinned_verified_kernel_archives(self) -> None:
        makefile = ISO_RECIPE.read_text(encoding="utf-8")

        for variable in (
            "LINUX_FIRMWARE_SHA256",
            "WIRELESS_REGDB_SHA256",
            "LINUX_FIRMWARE_URL",
            "LINUX_FIRMWARE_FALLBACK_URL",
            "WIRELESS_REGDB_URL",
            "WIRELESS_REGDB_FALLBACK_URL",
        ):
            self.assertIn(f"{variable} = ", makefile)
        self.assertEqual(makefile.count("scripts/download-verified-archive.sh"), 2)
        self.assertIn("https://cdn.kernel.org/pub/linux/kernel/firmware/", makefile)
        self.assertIn(
            "https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/", makefile
        )
        self.assertIn(
            "https://cdn.kernel.org/pub/software/network/wireless-regdb/", makefile
        )
        self.assertIn(
            "https://mirrors.edge.kernel.org/pub/software/network/wireless-regdb/",
            makefile,
        )
        self.assertIn(
            "https://cdn.kernel.org/pub/linux/kernel/firmware/sha256sums.asc",
            makefile,
        )
        self.assertIn(
            "https://cdn.kernel.org/pub/software/network/wireless-regdb/sha256sums.asc",
            makefile,
        )
        self.assertNotIn(
            "git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git",
            makefile,
        )
        self.assertIn('"linux-firmware-$(LINUX_FIRMWARE_TAG)/WHENCE"', makefile)
        self.assertIn(
            'rm -f "$(LINUX_FIRMWARE_PATH)/.arkana-source-sha256" && \\',
            makefile,
        )
        self.assertIn(
            '"linux-firmware-$(LINUX_FIRMWARE_TAG)/WHENCE" && \\\n\t  printf',
            makefile,
        )
        for firmware in ("amdgpu", "i915", "xe", "radeon", "amd-ucode", "intel", "LICENSES"):
            self.assertIn(f'"$(LINUX_FIRMWARE_PATH)/{firmware}"', makefile)
        self.assertIn(
            '"wireless-regdb-$(WIRELESS_REGDB_VERSION)"',
            makefile,
        )
        self.assertIn(
            'rm -f "$(WIRELESS_REGDB_PATH)/.arkana-source-sha256" && \\',
            makefile,
        )
        self.assertIn(
            '"wireless-regdb-$(WIRELESS_REGDB_VERSION)" && \\\n\t  printf',
            makefile,
        )
        for required in ("regulatory.db", "regulatory.db.p7s", "LICENSE"):
            self.assertIn(f'"$(WIRELESS_REGDB_PATH)/{required}"', makefile)

    def test_interrupted_firmware_repair_invalidates_a_matching_marker(self) -> None:
        makefile = ISO_RECIPE.read_text(encoding="utf-8")
        start = makefile.index(
            'if ! [ -f "$(LINUX_FIRMWARE_PATH)/.arkana-source-sha256"'
        )
        end = makefile.index("\n\tfi", start) + len("\n\tfi")
        shell_recipe = makefile[start:end]
        self.assertLess(
            shell_recipe.index('rm -f "$(LINUX_FIRMWARE_PATH)/.arkana-source-sha256"'),
            shell_recipe.index("tar -xJf"),
        )

        marker = self.root / "firmware-source" / ".arkana-source-sha256"
        source = marker.parent
        source.mkdir(parents=True)
        marker.write_text(f"{EXPECTED_SHA256}\n", encoding="utf-8")
        for directory in (
            "amdgpu",
            "i915",
            "xe",
            "radeon",
            "amd-ucode",
            "intel",
            "LICENSES",
        ):
            (source / directory).mkdir()

        fake_tar = self.bin_dir / "tar"
        fake_tar.write_text(
            "#!/usr/bin/env python3\n"
            "import os, pathlib, sys\n"
            "args = sys.argv[1:]\n"
            "destination = pathlib.Path(args[args.index('-C') + 1])\n"
            "calls = pathlib.Path(os.environ['TAR_CALLS'])\n"
            "count = int(calls.read_text()) + 1 if calls.exists() else 1\n"
            "calls.write_text(str(count))\n"
            "(destination / 'WHENCE').write_text('restored sentinel\\n')\n"
            "if count > 1:\n"
            "    (destination / 'amdgpu' / 'complete.bin').write_bytes(b'complete')\n"
            "raise SystemExit(2 if count == 1 else 0)\n",
            encoding="utf-8",
        )
        fake_tar.chmod(0o755)
        environment = self.environment.copy()
        environment.update(
            {
                "PATH": f"{self.bin_dir}{os.pathsep}{os.environ['PATH']}",
                "TAR_CALLS": str(self.root / "tar-calls"),
            }
        )
        replacements = {
            "$(LINUX_FIRMWARE_PATH)": str(source),
            "$(LINUX_FIRMWARE_SHA256)": EXPECTED_SHA256,
            "$(LINUX_FIRMWARE_ARCHIVE)": str(self.root / "firmware.tar.xz"),
            "$(LINUX_FIRMWARE_TAG)": "20260916",
        }
        for variable, value in replacements.items():
            shell_recipe = shell_recipe.replace(variable, value)

        interrupted = subprocess.run(
            ["bash", "-c", shell_recipe],
            check=False,
            capture_output=True,
            env=environment,
            text=True,
            timeout=10,
        )
        self.assertNotEqual(interrupted.returncode, 0)
        self.assertFalse(marker.exists())
        self.assertEqual((self.root / "tar-calls").read_text(), "1")

        retried = subprocess.run(
            ["bash", "-c", shell_recipe],
            check=False,
            capture_output=True,
            env=environment,
            text=True,
            timeout=10,
        )
        self.assertEqual(retried.returncode, 0, retried.stderr)
        self.assertEqual((self.root / "tar-calls").read_text(), "2")
        self.assertEqual(marker.read_text(encoding="utf-8"), f"{EXPECTED_SHA256}\n")
        self.assertEqual((source / "amdgpu" / "complete.bin").read_bytes(), b"complete")

    def test_firmware_tar_selection_extracts_expected_relative_paths(self) -> None:
        archive = self.root / "firmware.tar.xz"
        archive_root = "linux-firmware-20260916"
        directories = (
            "amdgpu",
            "i915",
            "xe",
            "radeon",
            "amd-ucode",
            "intel",
            "LICENSES",
        )
        with tarfile.open(archive, "w:xz") as bundle:
            for directory in directories:
                entry = tarfile.TarInfo(f"{archive_root}/{directory}/")
                entry.type = tarfile.DIRTYPE
                entry.mode = 0o755
                bundle.addfile(entry)
                payload = b"firmware extraction fixture\n"
                entry = tarfile.TarInfo(f"{archive_root}/{directory}/fixture.bin")
                entry.size = len(payload)
                entry.mode = 0o644
                bundle.addfile(entry, io.BytesIO(payload))
            payload = b"fixture license map\n"
            entry = tarfile.TarInfo(f"{archive_root}/WHENCE")
            entry.size = len(payload)
            entry.mode = 0o644
            bundle.addfile(entry, io.BytesIO(payload))

        extracted = self.root / "extracted"
        extracted.mkdir()
        result = subprocess.run(
            [
                "tar",
                "-xJf",
                str(archive),
                "--no-same-owner",
                "--no-same-permissions",
                "--strip-components=1",
                "-C",
                str(extracted),
                *(f"{archive_root}/{directory}" for directory in directories),
                f"{archive_root}/WHENCE",
            ],
            check=False,
            capture_output=True,
            text=True,
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        for directory in directories:
            self.assertEqual(
                (extracted / directory / "fixture.bin").read_bytes(),
                b"firmware extraction fixture\n",
            )
        self.assertEqual((extracted / "WHENCE").read_text(), "fixture license map\n")


if __name__ == "__main__":
    unittest.main()
