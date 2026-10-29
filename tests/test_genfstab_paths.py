"""Regression tests for genfstab root-prefix handling."""

from __future__ import annotations

import subprocess
import unittest
from pathlib import Path

GENFSTAB = Path(__file__).resolve().parents[1] / "genfstab"


class GenfstabRootPathTests(unittest.TestCase):
    def test_root_prefix_removal_quotes_shell_pattern_characters(self) -> None:
        """Keep glob characters in mount roots literal during prefix removal."""
        source = GENFSTAB.read_text(encoding="utf-8")
        self.assertIn('target=${target#"$root"}', source)
        self.assertIn('src="/${src#"$root"/}"', source)
        self.assertIn('"${device#"${root%/}"}"', source)

        root = "/tmp/arkana[os]"
        script = r"""root=$1
target=$2
src=$3
device=$4
target=${target#"$root"}
src="/${src#"$root"/}"
device=${device#"${root%/}"}
printf '%s\n%s\n%s\n' "$target" "$src" "$device"
"""
        result = subprocess.run(
            [
                "bash",
                "-c",
                script,
                "bash",
                root,
                f"{root}/boot",
                f"{root}/dev/sda",
                f"{root}/swap.img",
            ],
            check=True,
            capture_output=True,
            text=True,
        )
        self.assertEqual(
            result.stdout.splitlines(), ["/boot", "/dev/sda", "/swap.img"]
        )


if __name__ == "__main__":
    unittest.main()
