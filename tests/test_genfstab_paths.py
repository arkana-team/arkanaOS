"""Regression tests for genfstab root-prefix handling."""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

GENFSTAB = Path(__file__).resolve().parents[1] / "genfstab"


class GenfstabRootPathTests(unittest.TestCase):
    def test_glob_characters_in_mount_bind_and_swap_paths(self) -> None:
        """Keep root prefixes literal in all generated fstab path types."""
        with tempfile.TemporaryDirectory(prefix="genfstab-root-") as temporary:
            temp_path = Path(temporary)
            root = temp_path / "arkana space[os] "
            root.mkdir()
            fake_bin = temp_path / "bin"
            fake_bin.mkdir()

            mountpoint = fake_bin / "mountpoint"
            mountpoint.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
            mountpoint.chmod(0o755)

            findmnt = fake_bin / "findmnt"
            findmnt.write_text(
                "#!/bin/sh\n"
                'if [ "$1" = "-Recvruno" ]; then\n'
                '  root=$GENFSTAB_RAW_ROOT\n'
                '  printf "/dev/root\\t%s\\text4\\trw,relatime\\t/\\n" "$root"\n'
                '  printf "/dev/boot\\t%s/boot\\text4\\trw,relatime\\t/\\n" "$root"\n'
                '  printf "/dev/root\\t%s/mnt/source\\text4\\trw,relatime\\t/dev/sda\\n" "$root"\n'
                'elif [ "$1" = "-funcevo" ]; then\n'
                '  printf "%s\\n" "$GENFSTAB_RAW_ROOT"\n'
                'elif [ "$1" = "/dev/root" ] && [ "$2" = "$GENFSTAB_TEST_ROOT" ]; then\n'
                "  exit 0\n"
                "else\n"
                "  exit 1\n"
                "fi\n",
                encoding="utf-8",
            )
            findmnt.chmod(0o755)

            lsblk = fake_bin / "lsblk"
            lsblk.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
            lsblk.chmod(0o755)

            swap_table = temp_path / "swaps"
            escaped_swap = str(root).replace(" ", "\\040")
            swap_table.write_text(
                "Filename Type Size Used Priority\n"
                f"{escaped_swap}/swap.img file 1048576 0 -2\n",
                encoding="utf-8",
            )
            source = GENFSTAB.read_text(encoding="utf-8")
            source = source.replace(
                "} </proc/swaps", f"}} <{swap_table}", 1
            )
            self.assertNotEqual(source, GENFSTAB.read_text(encoding="utf-8"))
            script = temp_path / "genfstab"
            script.write_text(source, encoding="utf-8")
            script.chmod(0o755)

            environment = os.environ.copy()
            environment["PATH"] = f"{fake_bin}:{environment['PATH']}"
            environment["GENFSTAB_TEST_ROOT"] = str(root)
            environment["GENFSTAB_RAW_ROOT"] = str(root).replace(" ", r"\x20")
            result = subprocess.run(
                [str(script), str(root)],
                check=True,
                capture_output=True,
                text=True,
                env=environment,
            )

        rows = [
            line.split()
            for line in result.stdout.splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        ]
        self.assertIn(["/dev/root", "/", "ext4", "rw,relatime", "0", "1"], rows)
        self.assertIn(["/dev/boot", "/boot", "ext4", "rw,relatime", "0", "2"], rows)
        self.assertIn(
            ["/dev/sda", "/mnt/source", "none", "rw,bind", "0", "0"],
            rows,
        )
        self.assertIn(["/swap.img", "none", "swap", "defaults", "0", "0"], rows)


if __name__ == "__main__":
    unittest.main()
