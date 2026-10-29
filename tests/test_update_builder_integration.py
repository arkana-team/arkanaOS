"""Exercise the update builder against the pinned ArkUp CLI and apply path."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
BUILDER = REPOSITORY / "scripts/build-update-pack.py"
ARKUP = os.environ.get("ARKUP_BIN") or shutil.which("arkup")
SYSTEM_METADATA = (
    "etc/arkana-build-number",
    "etc/arkana-release-prefix",
    "etc/arkana-release-id",
    "etc/arkana-release-version",
    "etc/arkana-release-version-id",
    "etc/arkana-release-prerelease",
    "etc/os-release",
    "etc/issue",
)


def create_release_tree(root: Path, build: int) -> None:
    version = "1.0 (alpha 1)"
    version_id = "1.0-alpha1"
    release_id = f"v1.0-alpha1-build-{build}"
    values = {
        "arkana-build-number": f"{build}\n",
        "arkana-release-prefix": "r1-a1\n",
        "arkana-release-id": f"{release_id}\n",
        "arkana-release-version": f"{version}\n",
        "arkana-release-version-id": f"{version_id}\n",
        "arkana-release-prerelease": "true\n",
        "os-release": (
            f'NAME=arkanaOS\nVERSION="{version} build {build}"\n'
            f'ID=arkana\nVERSION_ID="{version_id}"\n'
            f'PRETTY_NAME="arkanaOS {version} build {build}"\n'
        ),
        "issue": f"arkanaOS {version} build {build}\n",
    }
    etc = root / "etc"
    etc.mkdir(parents=True)
    for name, contents in values.items():
        (etc / name).write_text(contents, encoding="utf-8")


@unittest.skipUnless(ARKUP, "set ARKUP_BIN to run the real ArkUp integration test")
class UpdateBuilderIntegrationTests(unittest.TestCase):
    def run_command(self, arguments: list[str]) -> subprocess.CompletedProcess[str]:
        result = subprocess.run(
            arguments,
            check=False,
            capture_output=True,
            text=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_system_metadata_overrides_local_edits_and_config_is_preserved(self) -> None:
        assert ARKUP is not None
        with tempfile.TemporaryDirectory(prefix="arkana-update-integration-") as temporary:
            root = Path(temporary)
            keys = root / "keys"
            base = root / "base"
            target = root / "target"
            install = root / "installed"
            output = root / "updates"
            initial_package = root / "initial.aup"

            create_release_tree(base, 10)
            create_release_tree(target, 11)
            live_overrides = (
                "etc/systemd/system/getty@tty1.service.d/override.conf",
                "etc/systemd/system/serial-getty@ttyS0.service.d/override.conf",
            )
            for relative in live_overrides:
                override = target / relative
                override.parent.mkdir(parents=True)
                override.write_text(
                    "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin root %I\n",
                    encoding="utf-8",
                )
            for release_root, default_value, executable in (
                (base, b"default=old\n", b"build-10\n"),
                (target, b"default=new\n", b"build-11\n"),
            ):
                (release_root / "etc/local.conf").write_bytes(default_value)
                binary = release_root / "usr/bin/arkana-integration-fixture"
                binary.parent.mkdir(parents=True)
                binary.write_bytes(executable)
                binary.chmod(0o755)
                if release_root == base:
                    retired = release_root / "usr/bin/retired-tool"
                    retired.write_bytes(b"retired\n")
            self.run_command([ARKUP, "keygen", "--output-dir", str(keys)])
            signing_key = next(keys.glob("*.key"))
            public_key = next(keys.glob("*.pub"))
            version = "arkanaOS 1.0 (alpha 1) build 10"
            initial_command = [
                ARKUP,
                "pack",
                "--source",
                str(base),
                "--name",
                "arkanaos-system",
                "--version",
                version,
                "--sequence",
                "10",
                "--arch",
                "x86_64",
                "--description",
                "integration-test base",
                "--signing-key",
                str(signing_key),
                "--output",
                str(initial_package),
            ]
            for path in SYSTEM_METADATA:
                initial_command.extend(("--system-file", path))
            self.run_command(initial_command)
            install.mkdir()
            self.run_command([ARKUP, "trust", str(public_key), "--root", str(install)])
            self.run_command(
                [ARKUP, "apply", str(initial_package), "--root", str(install), "--arch", "x86_64"]
            )

            (install / "etc/os-release").write_text("LOCALLY_EDITED=1\n", encoding="utf-8")
            (install / "etc/issue").write_text("locally edited issue\n", encoding="utf-8")
            (install / "etc/local.conf").write_text("local=preserve\n", encoding="utf-8")

            self.run_command(
                [
                    sys.executable,
                    str(BUILDER),
                    "--base-root",
                    str(base),
                    "--target-root",
                    str(target),
                    "--output-dir",
                    str(output),
                    "--signing-key",
                    str(signing_key),
                    "--public-key",
                    str(public_key),
                    "--arkup",
                    ARKUP,
                ]
            )
            package = next(output.glob("*.aup"))
            self.run_command(
                [ARKUP, "apply", str(package), "--root", str(install), "--arch", "x86_64"]
            )

            self.assertEqual(
                (install / "etc/os-release").read_bytes(),
                (target / "etc/os-release").read_bytes(),
            )
            self.assertEqual(
                (install / "etc/issue").read_bytes(),
                (target / "etc/issue").read_bytes(),
            )
            self.assertFalse((install / "etc/os-release.arkup-new").exists())
            self.assertEqual((install / "etc/local.conf").read_text(), "local=preserve\n")
            self.assertEqual(
                (install / "etc/local.conf.arkup-new").read_text(),
                "default=new\n",
            )
            self.assertEqual(
                (install / "usr/bin/arkana-integration-fixture").read_bytes(),
                b"build-11\n",
            )
            self.assertFalse((install / "usr/bin/retired-tool").exists())
            for relative in live_overrides:
                self.assertFalse(os.path.lexists(install / relative))
                self.assertFalse(os.path.lexists(install / f"{relative}.arkup-new"))
                self.assertTrue((target / relative).is_file())

    def test_weekly_fanout_builds_and_applies_each_exact_base_package(self) -> None:
        assert ARKUP is not None
        with tempfile.TemporaryDirectory(prefix="arkana-weekly-fanout-") as temporary:
            root = Path(temporary)
            keys = root / "keys"
            output = root / "updates"
            target = root / "target"
            bases = {build: root / f"base-{build}" for build in (9, 10)}
            installs = {build: root / f"installed-{build}" for build in (9, 10)}

            for build, base in bases.items():
                create_release_tree(base, build)
                (base / "etc/workstation.conf").write_text(
                    f"base={build}\n", encoding="utf-8"
                )
            create_release_tree(target, 11)
            (target / "etc/workstation.conf").write_text("base=11\n", encoding="utf-8")
            self.run_command([ARKUP, "keygen", "--output-dir", str(keys)])
            signing_key = next(keys.glob("*.key"))
            public_key = next(keys.glob("*.pub"))

            for build, base in bases.items():
                initial_package = root / f"base-{build}.aup"
                initial_command = [
                    ARKUP, "pack", "--source", str(base), "--name", "arkanaos-system",
                    "--version", f"arkanaOS 1.0 (alpha 1) build {build}",
                    "--sequence", str(build), "--arch", "x86_64",
                    "--description", f"weekly fanout base build {build}",
                    "--signing-key", str(signing_key), "--output", str(initial_package),
                ]
                for path in SYSTEM_METADATA:
                    initial_command.extend(("--system-file", path))
                self.run_command(initial_command)
                installs[build].mkdir()
                self.run_command([ARKUP, "trust", str(public_key), "--root", str(installs[build])])
                self.run_command([
                    ARKUP, "apply", str(initial_package), "--root", str(installs[build]),
                    "--arch", "x86_64",
                ])
                self.run_command([
                    sys.executable, str(BUILDER), "--base-root", str(base),
                    "--target-root", str(target), "--output-dir", str(output),
                    "--signing-key", str(signing_key), "--public-key", str(public_key),
                    "--arkup", ARKUP,
                ])

            packages = {
                build: output / f"arkanaos-v1.0-alpha1-build-11-from-build-{build}.aup"
                for build in bases
            }
            for build, package in packages.items():
                self.assertTrue(package.is_file(), package)
                self.assertTrue(Path(f"{package}.sha256").is_file())
                wrong_base = next(candidate for candidate in packages if candidate != build)
                rejected = subprocess.run(
                    [ARKUP, "apply", str(packages[wrong_base]), "--root", str(installs[build]), "--arch", "x86_64"],
                    check=False, capture_output=True, text=True,
                )
                self.assertNotEqual(rejected.returncode, 0, rejected.stdout + rejected.stderr)
                self.assertEqual(
                    (installs[build] / "etc/arkana-build-number").read_text().strip(),
                    str(build),
                )
                self.run_command([
                    ARKUP, "apply", str(package), "--root", str(installs[build]),
                    "--arch", "x86_64",
                ])
                self.assertEqual(
                    (installs[build] / "etc/arkana-build-number").read_text().strip(),
                    "11",
                )
                self.assertEqual(
                    (installs[build] / "etc/workstation.conf").read_text(),
                    "base=11\n",
                )


if __name__ == "__main__":
    unittest.main(verbosity=2)
