#!/usr/bin/env python3
"""Safety tests for pruning optional development files from an ISO root."""

from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "prune-optional-devel"


class PruneOptionalDevelTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.root = self.work / "output/iso-root"
        self.root.mkdir(parents=True)
        self.script = self.work / SCRIPT.name
        shutil.copy2(SCRIPT, self.script)

    def mark_root(self) -> None:
        (self.root / ".arkana-iso-root").write_text(
            "arkanaOS ISO root\n", encoding="utf-8"
        )

    def run_pruner(self) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(self.script)],
            capture_output=True,
            text=True,
            check=False,
            cwd=self.work,
        )

    def test_prunes_development_files_and_keeps_runtime_files(self) -> None:
        header = self.root / "usr/include/X11/Xlib.h"
        header.parent.mkdir(parents=True)
        header.write_text("header", encoding="utf-8")
        runtime_library = self.root / "usr/lib/libX11.so.6"
        runtime_library.parent.mkdir(parents=True)
        runtime_library.write_text("runtime", encoding="utf-8")
        pc_file = self.root / "usr/lib/pkgconfig/x11.pc"
        pc_file.parent.mkdir(parents=True)
        pc_file.write_text("development metadata", encoding="utf-8")
        self.mark_root()

        result = self.run_pruner()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(header.exists())
        self.assertFalse(pc_file.exists())
        self.assertEqual(runtime_library.read_text(encoding="utf-8"), "runtime")
        self.assertFalse((self.root / ".arkana-iso-root").exists())

    def test_refuses_unmarked_root_without_removing_files(self) -> None:
        header = self.root / "usr/include/X11/Xlib.h"
        header.parent.mkdir(parents=True)
        header.write_text("header", encoding="utf-8")

        result = self.run_pruner()

        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(header.is_file())

    def test_rejects_caller_selected_root(self) -> None:
        alternate = self.work / "outside/iso-root"
        header = alternate / "usr/include/X11/Xlib.h"
        header.parent.mkdir(parents=True)
        header.write_text("keep", encoding="utf-8")
        (alternate / ".arkana-iso-root").write_text(
            "arkanaOS ISO root\n", encoding="utf-8"
        )

        result = subprocess.run(
            [sys.executable, str(self.script), str(alternate)],
            capture_output=True,
            text=True,
            check=False,
            cwd=self.work,
        )

        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(header.is_file())

    def test_refuses_symlinked_iso_root(self) -> None:
        outside = self.work / "outside/iso-root"
        header = outside / "usr/include/X11/Xlib.h"
        header.parent.mkdir(parents=True)
        header.write_text("keep", encoding="utf-8")
        (outside / ".arkana-iso-root").write_text(
            "arkanaOS ISO root\n", encoding="utf-8"
        )
        self.root.rmdir()
        self.root.symlink_to(outside, target_is_directory=True)

        result = self.run_pruner()

        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(header.is_file())

    def test_refuses_symlinked_output_directory(self) -> None:
        outside = self.work / "outside"
        outside_root = outside / "iso-root"
        header = outside_root / "usr/include/X11/Xlib.h"
        header.parent.mkdir(parents=True)
        header.write_text("keep", encoding="utf-8")
        (outside_root / ".arkana-iso-root").write_text(
            "arkanaOS ISO root\n", encoding="utf-8"
        )
        self.root.rmdir()
        (self.work / "output").rmdir()
        (self.work / "output").symlink_to(outside, target_is_directory=True)

        result = self.run_pruner()

        self.assertNotEqual(result.returncode, 0)
        self.assertTrue(header.is_file())

    def test_does_not_follow_symlinked_directory_patterns_outside_root(self) -> None:
        outside = self.work / "outside"
        outside.mkdir()
        protected_file = outside / "libX11.pc"
        protected_file.write_text("keep", encoding="utf-8")
        package_config = self.root / "usr/lib/pkgconfig"
        package_config.parent.mkdir(parents=True)
        package_config.symlink_to(outside, target_is_directory=True)
        self.mark_root()

        result = self.run_pruner()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(protected_file.read_text(encoding="utf-8"), "keep")

    def test_does_not_follow_symlinked_static_paths_outside_root(self) -> None:
        outside = self.work / "outside"
        header = outside / "X11/Xlib.h"
        header.parent.mkdir(parents=True)
        header.write_text("keep", encoding="utf-8")
        usr = self.root / "usr"
        usr.mkdir()
        (usr / "include").symlink_to(outside, target_is_directory=True)
        self.mark_root()

        result = self.run_pruner()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(header.read_text(encoding="utf-8"), "keep")


if __name__ == "__main__":
    unittest.main()
