#!/usr/bin/env python3
"""Safety tests for pruning documentation from a marked ISO root."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "prune-runtime-docs"


class PruneRuntimeDocsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.root = self.work / "iso-root"
        self.root.mkdir()

    def mark_root(self) -> None:
        (self.root / ".arkana-iso-root").write_text(
            "arkanaOS ISO root\n", encoding="utf-8"
        )

    def run_pruner(self) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(SCRIPT), str(self.root)],
            capture_output=True,
            text=True,
            check=False,
        )

    def test_prunes_docs_and_caches_but_preserves_help_and_licenses(self) -> None:
        docs = self.root / "usr/share/doc"
        ordinary = docs / "optional-tool/readme.txt"
        ordinary.parent.mkdir(parents=True)
        ordinary.write_text("docs", encoding="utf-8")
        license_file = docs / "optional-tool/copyright"
        license_file.write_text("license", encoding="utf-8")
        help_file = docs / "nscde/help.txt"
        help_file.parent.mkdir()
        help_file.write_text("help", encoding="utf-8")
        cache = self.root / "usr/lib/python3.13/__pycache__/module.pyc"
        cache.parent.mkdir(parents=True)
        cache.write_bytes(b"bytecode")
        self.mark_root()

        result = self.run_pruner()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((docs / "optional-tool").exists())
        self.assertEqual(help_file.read_text(encoding="utf-8"), "help")
        self.assertEqual(
            (self.root / "usr/share/licenses/documentation/optional-tool/copyright")
            .read_text(encoding="utf-8"),
            "license",
        )
        self.assertFalse(cache.exists())

    def test_refuses_unmarked_root_without_removing_docs(self) -> None:
        docs = self.root / "usr/share/doc/optional-tool"
        docs.mkdir(parents=True)
        protected = docs / "readme.txt"
        protected.write_text("keep", encoding="utf-8")

        result = self.run_pruner()

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(protected.read_text(encoding="utf-8"), "keep")

    def test_refuses_docs_symlinked_outside_root(self) -> None:
        outside = self.work / "outside-docs"
        protected = outside / "optional-tool/readme.txt"
        protected.parent.mkdir(parents=True)
        protected.write_text("keep", encoding="utf-8")
        docs_parent = self.root / "usr/share"
        docs_parent.mkdir(parents=True)
        (docs_parent / "doc").symlink_to(outside, target_is_directory=True)
        self.mark_root()

        result = self.run_pruner()

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(protected.read_text(encoding="utf-8"), "keep")

    def test_skips_symlinked_python_tree_outside_root(self) -> None:
        docs = self.root / "usr/share/doc/nscde"
        docs.mkdir(parents=True)
        (docs / "help.txt").write_text("help", encoding="utf-8")
        outside = self.work / "outside-python"
        cache = outside / "__pycache__/module.pyc"
        cache.parent.mkdir(parents=True)
        cache.write_bytes(b"keep")
        python_lib = self.root / "usr/lib"
        python_lib.mkdir(parents=True)
        (python_lib / "python3.13").symlink_to(outside, target_is_directory=True)
        self.mark_root()

        result = self.run_pruner()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(cache.read_bytes(), b"keep")


if __name__ == "__main__":
    unittest.main()
