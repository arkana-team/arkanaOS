#!/usr/bin/env python3
"""Exercise release metadata generation using isolated build-number files."""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]
MAKEFILE = REPOSITORY / "arkanas/01_base.mk"


class ReleaseMetadataTests(unittest.TestCase):
    def run_timestamp(self, root: Path, prefix: str) -> subprocess.CompletedProcess[str]:
        build_number = root / ".buildnum"
        build_number.write_text("232\n", encoding="ascii")
        build_number.chmod(0o644)
        environment = os.environ.copy()
        environment.pop("ARKANA_BUILD_NUMBER", None)
        environment["ARKANA_RELEASE_PREFIX"] = prefix
        return subprocess.run(
            [
                "make",
                "-f",
                str(MAKEFILE),
                "release-metadata",
                f"BUILDNUM_FILE={build_number}",
                f"STAGING_PATH={root / 'staging'}",
            ],
            cwd=REPOSITORY,
            env=environment,
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )

    def test_valid_release_labels_write_expected_metadata(self) -> None:
        cases = (
            ("nightly", "nightly", "nightly", "nightly-build-233", "true"),
            (
                "r1-a1",
                "1.0 (alpha 1)",
                "1.0-alpha1",
                "v1.0-alpha1-build-233",
                "true",
            ),
            (
                "r1-b1",
                "1.0 (beta 1)",
                "1.0-beta1",
                "v1.0-beta1-build-233",
                "true",
            ),
            ("r1-1", "1.0", "1.0", "v1.0-build-233", "false"),
        )
        for prefix, version, version_id, release_id, prerelease in cases:
            with self.subTest(prefix=prefix), tempfile.TemporaryDirectory(
                prefix="arkana-release-metadata-"
            ) as temporary:
                root = Path(temporary)
                result = self.run_timestamp(root, prefix)
                self.assertEqual(result.returncode, 0, result.stderr)
                metadata = root / "staging/etc"
                self.assertEqual(
                    (metadata / "arkana-build-number").read_text().strip(), "233"
                )
                self.assertEqual(
                    (metadata / "arkana-release-prefix").read_text().strip(), prefix
                )
                self.assertEqual(
                    (metadata / "arkana-release-id").read_text().strip(),
                    release_id,
                )
                self.assertEqual(
                    (metadata / "arkana-release-version").read_text().strip(), version
                )
                self.assertEqual(
                    (metadata / "arkana-release-version-id").read_text().strip(),
                    version_id,
                )
                self.assertEqual(
                    (metadata / "arkana-release-prerelease").read_text().strip(),
                    prerelease,
                )
                os_release = (metadata / "os-release").read_text(encoding="utf-8")
                self.assertIn(f'VERSION="{version} build 233"', os_release)
                self.assertIn(f'VERSION_ID="{version_id}"', os_release)
                self.assertIn(
                    f'PRETTY_NAME="arkanaOS {version} build 233"', os_release
                )
                self.assertEqual(
                    (metadata / "issue").read_text(encoding="utf-8").strip(),
                    f"arkanaOS {version} build 233",
                )

    def test_invalid_release_label_does_not_consume_build_number(self) -> None:
        with tempfile.TemporaryDirectory(prefix="arkana-release-metadata-") as temporary:
            root = Path(temporary)
            result = self.run_timestamp(root, "r1-alpha1")

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Invalid ARKANA_RELEASE_PREFIX", result.stderr)
            self.assertEqual((root / ".buildnum").read_text().strip(), "232")
            self.assertFalse((root / "staging/etc/arkana-release-id").exists())


if __name__ == "__main__":
    unittest.main()
