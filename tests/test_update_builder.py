#!/usr/bin/env python3
"""Test update metadata validation, delta safety, and arkup invocation."""

from __future__ import annotations

import hashlib
import importlib.util
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "scripts/build-update-pack.py"
SPEC = importlib.util.spec_from_file_location("arkana_update_builder", SCRIPT)
assert SPEC and SPEC.loader
builder = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = builder
SPEC.loader.exec_module(builder)


def release_files(root: Path, build: int, prefix: str = "r1-a1") -> None:
    root.mkdir(parents=True, exist_ok=True)
    if prefix == "nightly":
        version, version_id, release_id, prerelease = (
            "nightly",
            "nightly",
            f"nightly-build-{build}",
            "true",
        )
    elif prefix == "r1-a1":
        version, version_id, release_id, prerelease = (
            "1.0 (alpha 1)",
            "1.0-alpha1",
            f"v1.0-alpha1-build-{build}",
            "true",
        )
    else:
        raise AssertionError(f"fixture does not support {prefix}")
    etc = root / "etc"
    etc.mkdir(exist_ok=True)
    values = {
        "arkana-build-number": f"{build}\n",
        "arkana-release-prefix": f"{prefix}\n",
        "arkana-release-id": f"{release_id}\n",
        "arkana-release-version": f"{version}\n",
        "arkana-release-version-id": f"{version_id}\n",
        "arkana-release-prerelease": f"{prerelease}\n",
        "os-release": (
            f'NAME=arkanaOS\nVERSION="{version} build {build}"\n'
            f'ID=arkana\nVERSION_ID="{version_id}"\n'
            f'PRETTY_NAME="arkanaOS {version} build {build}"\n'
        ),
        "issue": f"arkanaOS {version} build {build}\n",
    }
    for name, value in values.items():
        (etc / name).write_text(value, encoding="utf-8")


class ReleaseMetadataTests(unittest.TestCase):
    def test_validates_nightly_to_alpha_metadata(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary) / "base"
            target = Path(temporary) / "target"
            release_files(base, 9, "nightly")
            release_files(target, 10, "r1-a1")
            self.assertEqual(builder.read_release(base).release_id, "nightly-build-9")
            self.assertEqual(builder.read_release(target).display, "1.0 (alpha 1) build 10")

    def test_rejects_inconsistent_os_release_and_malformed_build(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary) / "root"
            release_files(root, 10)
            (root / "etc/os-release").write_text("NAME=other\n", encoding="utf-8")
            with self.assertRaisesRegex(builder.BuildError, "os-release"):
                builder.read_release(root)

            (root / "etc/os-release").write_text(
                'NAME=arkanaOS\nVERSION="1.0 (alpha 1) build 10"\n'
                'ID=arkana\nVERSION_ID="1.0-alpha1"\n'
                'PRETTY_NAME="arkanaOS 1.0 (alpha 1) build 10"\n',
                encoding="utf-8",
            )
            (root / "etc/arkana-build-number").write_text("10x\n", encoding="ascii")
            with self.assertRaisesRegex(builder.BuildError, "build number"):
                builder.read_release(root)

    def test_release_metadata_cannot_escape_through_directory_symlinks(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary)
            outside = workspace / "outside"
            root = workspace / "root"
            release_files(outside, 10)
            root.mkdir()
            os.symlink(outside / "etc", root / "etc")
            with self.assertRaisesRegex(builder.BuildError, "parent must be a real directory"):
                builder.read_release(root)


class DeltaTests(unittest.TestCase):
    def test_tracks_changed_modes_symlinks_additions_and_deletions(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            base_root = Path(temporary) / "base"
            target_root = Path(temporary) / "target"
            (base_root / "usr/bin").mkdir(parents=True)
            (target_root / "usr/bin").mkdir(parents=True)
            (base_root / "usr/bin/tool").write_text("old\n", encoding="utf-8")
            (target_root / "usr/bin/tool").write_text("new\n", encoding="utf-8")
            (base_root / "usr/bin/retired").write_text("remove\n", encoding="utf-8")
            os.symlink("tool", base_root / "usr/bin/current")
            os.symlink("new-tool", target_root / "usr/bin/current")
            (target_root / "usr/bin/new-tool").write_text("new file\n", encoding="utf-8")
            (base_root / "usr/bin/tool").chmod(0o755)
            (target_root / "usr/bin/tool").chmod(0o700)

            changed, deleted = builder.compute_delta(
                builder.snapshot_tree(base_root), builder.snapshot_tree(target_root)
            )
            self.assertEqual(changed, ["usr/bin/current", "usr/bin/new-tool", "usr/bin/tool"])
            self.assertEqual(deleted, ["usr/bin/retired"])

    def test_ignores_protected_state_and_iso_marker(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            base = Path(temporary) / "base"
            target = Path(temporary) / "target"
            for root, contents in ((base, b"old"), (target, b"new")):
                (root / "etc/arkup").mkdir(parents=True)
                (root / "etc/arkpkg").mkdir()
                (root / "var/lib/arkup").mkdir(parents=True)
                (root / "var/lib/dbus").mkdir(parents=True)
                (root / "var/cache").mkdir(parents=True)
                (root / "var/spool/mail").mkdir(parents=True)
                (root / "home/tester").mkdir(parents=True)
                (root / "root").mkdir()
                (root / "srv/site").mkdir(parents=True)
                (root / "usr/local/bin").mkdir(parents=True)
                (root / "run").mkdir()
                (root / "etc/ld.so.cache").write_bytes(contents)
                (root / "etc/arkup/state").write_bytes(contents)
                (root / "etc/arkpkg/repos.json").write_bytes(contents)
                (root / "var/lib/arkup/state").write_bytes(contents)
                (root / "var/lib/dbus/machine-id").write_bytes(contents)
                (root / "var/cache/data").write_bytes(contents)
                (root / "var/spool/mail/tester").write_bytes(contents)
                (root / "home/tester/data").write_bytes(contents)
                (root / "root/.bashrc").write_bytes(contents)
                (root / "srv/site/index.html").write_bytes(contents)
                (root / "usr/local/bin/local-tool").write_bytes(contents)
                (root / "run/session").write_bytes(contents)
                (root / "etc/localtime").symlink_to("/usr/share/zoneinfo/UTC")
                (root / "etc/resolv.conf").symlink_to("/run/systemd/resolve/stub-resolv.conf")
                (root / ".arkana-iso-root").write_text("arkanaOS ISO root\n", encoding="utf-8")

            changed, deleted = builder.compute_delta(
                builder.snapshot_tree(base), builder.snapshot_tree(target)
            )
            self.assertEqual(changed, [])
            self.assertEqual(deleted, [])

    def test_rejects_file_directory_and_directory_mode_transitions(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            base = root / "base"
            target = root / "target"
            base.mkdir()
            (base / "usr").mkdir()
            (base / "usr/item").write_text("file", encoding="utf-8")
            (target / "usr/item").mkdir(parents=True)
            (target / "usr/item/child").write_text("child", encoding="utf-8")
            with self.assertRaisesRegex(builder.BuildError, "file/directory transition"):
                builder.compute_delta(builder.snapshot_tree(base), builder.snapshot_tree(target))

            (target / "usr/item/child").unlink()
            (target / "usr/item").rmdir()
            (target / "usr/item").write_text("file", encoding="utf-8")
            (target / "usr").chmod(0o700)
            with self.assertRaisesRegex(builder.BuildError, "directory permissions"):
                builder.compute_delta(builder.snapshot_tree(base), builder.snapshot_tree(target))

    def test_rejects_special_files_and_unsafe_output_roots(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary) / "root"
            root.mkdir()
            os.mkfifo(root / "fifo")
            with self.assertRaisesRegex(builder.BuildError, "unsupported filesystem object"):
                builder.snapshot_tree(root)


class PackBuildTests(unittest.TestCase):
    def test_builds_verified_delta_with_release_files_marked_managed(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary)
            base = workspace / "base"
            target = workspace / "target"
            output = workspace / "updates"
            release_files(base, 10, "nightly")
            release_files(target, 11)
            (base / "usr/bin").mkdir(parents=True)
            (target / "usr/bin").mkdir(parents=True)
            (base / "usr/bin/tool").write_text("old\n", encoding="utf-8")
            (target / "usr/bin/tool").write_text("new\n", encoding="utf-8")
            (base / "usr/bin/retired").write_text("retired\n", encoding="utf-8")
            key = workspace / "release.key"
            public = workspace / "release.pub"
            key.write_text("private test key\n", encoding="ascii")
            public.write_text("public test key\n", encoding="ascii")

            calls: list[list[str]] = []

            def fake_run(command: list[str], *, check: bool) -> None:
                self.assertTrue(check)
                calls.append(command)
                if command[1] == "pack":
                    package = Path(command[command.index("--output") + 1])
                    package.write_bytes(b"verified test package")

            with patch.object(builder.subprocess, "run", side_effect=fake_run):
                package = builder.build_update(
                    base,
                    target,
                    output,
                    key,
                    public,
                    arkup="arkup-test",
                )

            self.assertIsNotNone(package)
            assert package
            self.assertEqual(package.name, "arkanaos-v1.0-alpha1-build-11.aup")
            self.assertEqual(package.stat().st_mode & 0o777, 0o644)
            self.assertEqual(len(calls), 2)
            pack = calls[0]
            self.assertIn("--sequence", pack)
            self.assertEqual(pack[pack.index("--sequence") + 1], "11")
            self.assertIn("--delete", pack)
            self.assertIn("usr/bin/retired", pack)
            for path in set(builder.SYSTEM_METADATA) - {"etc/arkana-release-prerelease"}:
                self.assertIn("--system-file", pack)
                self.assertIn(path, pack)
            self.assertNotIn("etc/ld.so.cache", pack)
            digest = hashlib.sha256(package.read_bytes()).hexdigest()
            self.assertEqual(
                package.with_name(package.name + ".sha256").read_text(encoding="ascii"),
                f"{digest}  {package.name}\n",
            )

    def test_rejects_non_newer_target_and_output_inside_source(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            workspace = Path(temporary)
            base = workspace / "base"
            target = workspace / "target"
            release_files(base, 10)
            release_files(target, 10)
            key = workspace / "release.key"
            public = workspace / "release.pub"
            key.touch()
            public.touch()
            with self.assertRaisesRegex(builder.BuildError, "must be newer"):
                builder.build_update(base, target, workspace / "out", key, public)

            release_files(target, 11)
            with self.assertRaisesRegex(builder.BuildError, "outside root trees"):
                builder.build_update(base, target, target / "out", key, public)
            self.assertFalse((target / "out").exists())


if __name__ == "__main__":
    unittest.main()
