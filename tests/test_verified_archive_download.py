"""Test integrity-checked source downloads and pinned build inputs."""

from __future__ import annotations

import gzip
import hashlib
import io
import json
import os
import shutil
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DOWNLOAD_SCRIPT = REPO_ROOT / "scripts/download-verified-archive.sh"
BASE_RECIPE = REPO_ROOT / "arkanas/01_base.mk"
GRAPHICS_RECIPE = REPO_ROOT / "arkanas/05_graphics.mk"
ISO_RECIPE = REPO_ROOT / "arkanas/07_iso.mk"
DOCKERFILE = REPO_ROOT / "Dockerfile"
PAYLOAD = b"pinned source archive fixture\n"
PRIMARY_URL = "https://cdn.example.invalid/source.tar.xz"
FALLBACK_URL = "https://mirror.example.invalid/source.tar.xz"
EXPECTED_SHA256 = hashlib.sha256(PAYLOAD).hexdigest()
KEYUTILS_SHA256 = "a61d5706136ae4c05bd48f86186bcfdbd88dd8bd5107e3e195c924cfc1b39bb4"
XTERM_SHA256 = "3da2b5e64cb49b03aa13057d85e62e1f2e64f7c744719c00d338d11cd3e6ca1a"


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
        self.assertEqual(makefile.count("scripts/download-verified-archive.sh"), 3)
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

    def test_grub_font_uses_pinned_verified_upstream_and_mirror(self) -> None:
        makefile = ISO_RECIPE.read_text(encoding="utf-8")

        self.assertIn("GRUB_FONT_VER = 16.0.01", makefile)
        self.assertIn(
            "GRUB_FONT_URL = https://unifoundry.com/pub/unifont/"
            "unifont-$(GRUB_FONT_VER)/font-builds/$(GRUB_FONT_ARCHIVE)",
            makefile,
        )
        self.assertIn(
            "GRUB_FONT_FALLBACK_URL = https://mirrors.ibiblio.org/"
            "pub/mirrors/gnu/unifont/unifont-$(GRUB_FONT_VER)/"
            "$(GRUB_FONT_ARCHIVE)",
            makefile,
        )
        self.assertIn(
            "GRUB_FONT_SHA256 = e756045ba0893ee2e8369b27afc02436"
            "bed90299db4e1672ce766e0470cd9825",
            makefile,
        )
        recipe_start = makefile.index(".grub-$(GRUB_VER)-obtained:")
        recipe_end = makefile.index("# Compile GRUB", recipe_start)
        recipe = makefile[recipe_start:recipe_end]
        self.assertIn("scripts/download-verified-archive.sh", recipe)
        self.assertIn("$(GRUB_FONT_SHA256)", recipe)
        self.assertIn("$(GRUB_FONT_FALLBACK_URL)", recipe)
        self.assertNotIn("-O unifont-16.0.01.pcf.gz", recipe)
        self.assertIn(
            "gunzip -c $(SRC_PATH)/$(GRUB_FONT_ARCHIVE)",
            makefile,
        )

    def test_grub_make_target_uses_verified_font_fallback_before_stamp(self) -> None:
        test_repo = self.root / "grub-recipe-repo"
        for relative_path in (
            Path("arkanas/07_iso.mk"),
            Path("arkanas/staging-guard.mk"),
            Path("arkanas/libpng.mk"),
            Path("scripts/download-verified-archive.sh"),
        ):
            destination = test_repo / relative_path
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(REPO_ROOT / relative_path, destination)
        (test_repo / ".buildnum").write_text("934\n", encoding="utf-8")
        source_dir = test_repo / "src"
        source_dir.mkdir()

        grub_payload_file = self.root / "grub-fixture.tar.xz"
        with tarfile.open(grub_payload_file, "w:xz") as archive:
            payload = b"fixture GRUB source archive\n"
            entry = tarfile.TarInfo("grub-2.16/fixture.txt")
            entry.size = len(payload)
            archive.addfile(entry, io.BytesIO(payload))
        grub_sha256 = hashlib.sha256(grub_payload_file.read_bytes()).hexdigest()

        font_payload = b"fixture PCF payload\n"
        self.payload_file.write_bytes(gzip.compress(font_payload))
        primary_url = "https://upstream.example.invalid/unifont.pcf.gz"
        fallback_url = "https://mirror.example.invalid/unifont.pcf.gz"
        grub_url = "https://grub.example.invalid/grub-2.16.tar.xz"
        self.environment.update(
            {
                "CURL_PAYLOAD": str(self.payload_file),
                "CURL_FAIL_URLS": json.dumps([primary_url, fallback_url]),
                "WGET_PAYLOAD": str(grub_payload_file),
                "WGET_CALLS": str(self.root / "wget-calls.jsonl"),
            }
        )
        fake_wget = self.bin_dir / "wget"
        fake_wget.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, pathlib, sys\n"
            "args = sys.argv[1:]\n"
            "output = pathlib.Path(args[args.index('-O') + 1])\n"
            "url = args[-1]\n"
            "with open(os.environ['WGET_CALLS'], 'a', encoding='utf-8') as log:\n"
            "    log.write(json.dumps(url) + '\\n')\n"
            "output.write_bytes(pathlib.Path(os.environ['WGET_PAYLOAD']).read_bytes())\n",
            encoding="utf-8",
        )
        fake_wget.chmod(0o755)

        command = [
            "make",
            "--no-print-directory",
            "-f",
            "arkanas/07_iso.mk",
            "download-grub",
            f"SRC_PATH={source_dir}",
            f"GRUB_URL={grub_url}",
            f"GRUB_SHA256={grub_sha256}",
            f"GRUB_FONT_URL={primary_url}",
            f"GRUB_FONT_FALLBACK_URL={fallback_url}",
            f"GRUB_FONT_SHA256={hashlib.sha256(self.payload_file.read_bytes()).hexdigest()}",
        ]
        failed_download = subprocess.run(
            command,
            check=False,
            capture_output=True,
            cwd=test_repo,
            env=self.environment,
            text=True,
            timeout=20,
        )
        stamp = test_repo / ".grub-2.16-obtained"
        self.assertNotEqual(failed_download.returncode, 0)
        self.assertIn("unable to download a SHA-256-verified archive", failed_download.stderr)
        self.assertFalse(stamp.exists())
        self.assertFalse((source_dir / "unifont-16.0.01.pcf.gz").exists())

        self.environment["CURL_FAIL_URLS"] = json.dumps([primary_url])
        retried_download = subprocess.run(
            command,
            check=False,
            capture_output=True,
            cwd=test_repo,
            env=self.environment,
            text=True,
            timeout=20,
        )
        self.assertEqual(retried_download.returncode, 0, retried_download.stderr)
        self.assertTrue(stamp.exists())
        self.assertEqual(
            gzip.decompress((source_dir / "unifont-16.0.01.pcf.gz").read_bytes()),
            font_payload,
        )
        self.assertEqual(
            (source_dir / "grub-2.16" / "fixture.txt").read_bytes(),
            b"fixture GRUB source archive\n",
        )
        self.assertEqual(
            [json.loads(line) for line in (self.root / "wget-calls.jsonl").read_text().splitlines()],
            [grub_url],
        )
        self.assertEqual(
            [call[-1] for call in self.recorded_calls()],
            [primary_url, fallback_url, primary_url, fallback_url],
        )

    def test_keyutils_recipe_uses_pinned_verified_sources(self) -> None:
        makefile = BASE_RECIPE.read_text(encoding="utf-8")

        self.assertIn(
            "KEYUTILS_URL = https://git.kernel.org/pub/scm/linux/kernel/git/"
            "dhowells/keyutils.git/snapshot/keyutils-1.6.3.tar.gz",
            makefile,
        )
        self.assertIn(
            "KEYUTILS_FALLBACK_URL = https://distfiles.gentoo.org/"
            "distfiles/b1/keyutils-1.6.3.tar.gz",
            makefile,
        )
        self.assertIn(f"KEYUTILS_SHA256 = {KEYUTILS_SHA256}", makefile)
        recipe_start = makefile.index(".keyutils-obtained:")
        recipe_end = makefile.index("# Compile keyutils", recipe_start)
        recipe = makefile[recipe_start:recipe_end]
        self.assertIn("scripts/download-verified-archive.sh", recipe)
        self.assertIn(
            "$(KEYUTILS_FALLBACK_URL) && \\\n\t  tar xf",
            recipe,
        )
        self.assertNotIn("wget", recipe)

    def test_xterm_recipe_uses_pinned_verified_upstream_and_mirror(self) -> None:
        makefile = GRAPHICS_RECIPE.read_text(encoding="utf-8")
        self.assertIn(
            "XTERM_URL = https://invisible-island.net/archives/xterm/xterm-401.tgz",
            makefile,
        )
        self.assertIn(
            "XTERM_FALLBACK_URL = https://invisible-mirror.net/archives/xterm/xterm-401.tgz",
            makefile,
        )
        self.assertIn(f"XTERM_SHA256 = {XTERM_SHA256}", makefile)
        recipe_start = makefile.index(".xterm-obtained:")
        recipe_end = makefile.index("# Compile xterm", recipe_start)
        recipe = makefile[recipe_start:recipe_end]
        self.assertIn("scripts/download-verified-archive.sh", recipe)
        self.assertIn('"$(XTERM_SHA256)" "$(XTERM_URL)" "$(XTERM_FALLBACK_URL)"', recipe)
        self.assertIn('tar xf "xterm-$(XTERM_VER).tgz"', recipe)
        self.assertNotIn("wget", recipe)

    def test_builder_image_installs_curl_for_verified_archive_downloads(self) -> None:
        dockerfile = DOCKERFILE.read_text(encoding="utf-8")
        self.assertRegex(dockerfile, r"(?m)^\s+curl\s+\\$")

    def test_keyutils_make_target_verifies_fallback_and_retries_partial_extract(self) -> None:
        real_tar = shutil.which("tar")
        self.assertIsNotNone(real_tar, "tar is required for this recipe integration test")

        test_repo = self.root / "recipe-repo"
        for relative_path in (
            Path("arkanas/01_base.mk"),
            Path("arkanas/staging-guard.mk"),
            Path("scripts/download-verified-archive.sh"),
        ):
            destination = test_repo / relative_path
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(REPO_ROOT / relative_path, destination)
        (test_repo / ".buildnum").write_text("933\n", encoding="utf-8")
        source_dir = test_repo / "src"
        source_dir.mkdir()

        with tarfile.open(self.payload_file, "w:gz") as archive:
            payload = b"fixture keyutils makefile\n"
            entry = tarfile.TarInfo("keyutils-1.6.3/Makefile")
            entry.size = len(payload)
            archive.addfile(entry, io.BytesIO(payload))
        fixture_sha256 = hashlib.sha256(self.payload_file.read_bytes()).hexdigest()

        primary_url = "https://upstream.example.invalid/keyutils-1.6.3.tar.gz"
        fallback_url = "https://mirror.example.invalid/keyutils-1.6.3.tar.gz"
        self.environment["CURL_PAYLOAD"] = str(self.payload_file)
        self.environment["CURL_FAIL_URLS"] = json.dumps([primary_url])
        self.environment["TAR_CALLS"] = str(self.root / "tar-calls")
        fake_tar = self.bin_dir / "tar"
        fake_tar.write_text(
            "#!/usr/bin/env python3\n"
            "import os, pathlib, sys\n"
            "calls = pathlib.Path(os.environ['TAR_CALLS'])\n"
            "count = int(calls.read_text()) + 1 if calls.exists() else 1\n"
            "calls.write_text(str(count))\n"
            "if count == 1:\n"
            "    partial = pathlib.Path('keyutils-1.6.3/Makefile')\n"
            "    partial.parent.mkdir()\n"
            "    partial.write_text('incomplete extraction')\n"
            "    raise SystemExit(2)\n"
            f"os.execv({real_tar!r}, [{real_tar!r}, *sys.argv[1:]])\n",
            encoding="utf-8",
        )
        fake_tar.chmod(0o755)

        command = [
            "make",
            "--no-print-directory",
            "-f",
            "arkanas/01_base.mk",
            "download-keyutils",
            f"SRC_PATH={source_dir}",
            f"KEYUTILS_URL={primary_url}",
            f"KEYUTILS_FALLBACK_URL={fallback_url}",
            f"KEYUTILS_SHA256={fixture_sha256}",
        ]
        interrupted = subprocess.run(
            command,
            check=False,
            capture_output=True,
            cwd=test_repo,
            env=self.environment,
            text=True,
            timeout=20,
        )
        self.assertNotEqual(interrupted.returncode, 0)
        self.assertIn("trying the verified fallback URL", interrupted.stderr)
        self.assertFalse((test_repo / ".keyutils-obtained").exists())
        self.assertTrue(
            (source_dir / "keyutils-1.6.3" / "Makefile")
            .read_text(encoding="utf-8")
            .startswith("incomplete")
        )
        self.assertEqual(
            [call[-1] for call in self.recorded_calls()], [primary_url, fallback_url]
        )

        retried = subprocess.run(
            command,
            check=False,
            capture_output=True,
            cwd=test_repo,
            env=self.environment,
            text=True,
            timeout=20,
        )
        self.assertEqual(retried.returncode, 0, retried.stderr)
        self.assertEqual((test_repo / ".keyutils-obtained").read_text(), "")
        self.assertEqual(
            (source_dir / "keyutils-1.6.3" / "Makefile").read_bytes(),
            b"fixture keyutils makefile\n",
        )
        self.assertEqual(
            [call[-1] for call in self.recorded_calls()], [primary_url, fallback_url]
        )

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
