"""Regression tests for the CI build-number seed step."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
SEED_SCRIPT = REPOSITORY / "scripts/seed-build-number.py"
ISO_WORKFLOW = REPOSITORY / ".github/workflows/04_stage4_iso.yml"
MAKEFILE = REPOSITORY / "arkanas/01_base.mk"


class BuildNumberSeedTests(unittest.TestCase):
    def run_seed(
        self, root: Path, current: str, tags: tuple[str, ...]
    ) -> subprocess.CompletedProcess[str]:
        build_file = root / ".buildnum"
        build_file.write_text(f"{current}\n", encoding="ascii")
        return subprocess.run(
            [sys.executable, str(SEED_SCRIPT), "--build-file", str(build_file)],
            input="\n".join(tags) + "\n",
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    def test_seeds_from_highest_build_across_release_tag_formats(self) -> None:
        tags = (
            "nightly-20261014-build-877",
            "nightly-908",
            "v1.0-alpha1-build-910",
            "v1.0-beta1-build-909",
            "v1.0-build-912",
            "v2.0-alpha2-build-911",
            "nightly-invalid",
        )
        with tempfile.TemporaryDirectory(prefix="arkana-build-seed-") as temporary:
            root = Path(temporary)
            result = self.run_seed(root, "907", tags)

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((root / ".buildnum").read_text().strip(), "912")
            self.assertIn("latest-published=912, seeded=912", result.stdout)

    def test_does_not_lower_ahead_checked_in_counter(self) -> None:
        with tempfile.TemporaryDirectory(prefix="arkana-build-seed-") as temporary:
            root = Path(temporary)
            result = self.run_seed(
                root, "920", ("nightly-908", "v1.0-alpha1-build-912")
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((root / ".buildnum").read_text().strip(), "920")

    def test_seeded_counter_increments_once_past_last_published_release(self) -> None:
        with tempfile.TemporaryDirectory(prefix="arkana-build-seed-") as temporary:
            root = Path(temporary)
            result = self.run_seed(
                root,
                "907",
                ("nightly-20261014-build-877", "nightly-908", "v1.0-alpha1-build-912"),
            )
            self.assertEqual(result.returncode, 0, result.stderr)

            arkanas = root / "arkanas"
            arkanas.mkdir()
            shutil.copy2(MAKEFILE, arkanas / MAKEFILE.name)
            shutil.copy2(
                MAKEFILE.with_name("staging-guard.mk"), arkanas / "staging-guard.mk"
            )
            environment = os.environ.copy()
            environment.pop("ARKANA_BUILD_NUMBER", None)
            environment["ARKANA_RELEASE_PREFIX"] = "nightly"
            build_result = subprocess.run(
                ["make", "-f", "arkanas/01_base.mk", "release-metadata"],
                cwd=root,
                env=environment,
                capture_output=True,
                text=True,
                timeout=30,
                check=False,
            )

            self.assertEqual(build_result.returncode, 0, build_result.stderr)
            self.assertEqual((root / ".buildnum").read_text().strip(), "913")
            self.assertEqual(
                (root / "staging/etc/arkana-release-id").read_text().strip(),
                "nightly-913",
            )

    def test_rejects_invalid_checked_in_counter_without_rewriting_it(self) -> None:
        with tempfile.TemporaryDirectory(prefix="arkana-build-seed-") as temporary:
            root = Path(temporary)
            build_file = root / ".buildnum"
            build_file.write_text("bad\n", encoding="ascii")
            result = subprocess.run(
                [sys.executable, str(SEED_SCRIPT), "--build-file", str(build_file)],
                input="nightly-999\n",
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(build_file.read_text(), "bad\n")

    def test_rejects_out_of_range_published_build_without_rewriting_counter(
        self,
    ) -> None:
        with tempfile.TemporaryDirectory(prefix="arkana-build-seed-") as temporary:
            root = Path(temporary)
            result = self.run_seed(
                root,
                "912",
                ("v1.0-alpha1-build-999999999999999999999999999999999999999",),
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertEqual((root / ".buildnum").read_text().strip(), "912")
            self.assertIn("supported build number range", result.stderr)

    def test_iso_workflow_seeds_before_running_the_iso_builder(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        step = "      - name: Seed build number from published releases\n"

        self.assertIn(step, workflow)
        self.assertIn("gh api --paginate", workflow)
        self.assertIn(
            "python3 scripts/seed-build-number.py --build-file .buildnum", workflow
        )
        self.assertIn("group: arkanaOS-release-${{ github.ref }}", workflow)
        self.assertIn("cancel-in-progress: false", workflow)
        self.assertLess(
            workflow.index(step),
            workflow.index("sudo --preserve-env make -f arkanas/07_iso.mk"),
        )


if __name__ == "__main__":
    unittest.main()
