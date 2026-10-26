#!/usr/bin/env python3
"""Exercise release metadata generation using isolated build-number files."""

from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]
MAKEFILE = REPOSITORY / "arkanas/01_base.mk"
ISO_WORKFLOW = REPOSITORY / ".github/workflows/04_stage4_iso.yml"


class ReleaseMetadataTests(unittest.TestCase):
    def run_timestamp(self, root: Path, prefix: str) -> subprocess.CompletedProcess[str]:
        build_number = root / ".buildnum"
        build_number.write_text("232\n", encoding="ascii")
        build_number.chmod(0o644)
        isolated_arkanas = root / "arkanas"
        isolated_arkanas.mkdir()
        shutil.copy2(MAKEFILE, isolated_arkanas / MAKEFILE.name)
        shutil.copy2(
            MAKEFILE.with_name("staging-guard.mk"),
            isolated_arkanas / "staging-guard.mk",
        )
        environment = os.environ.copy()
        environment.pop("ARKANA_BUILD_NUMBER", None)
        environment["ARKANA_RELEASE_PREFIX"] = prefix
        return subprocess.run(
            [
                "make",
                "-f",
                "arkanas/01_base.mk",
                "release-metadata",
            ],
            cwd=root,
            env=environment,
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )

    def test_valid_release_labels_write_expected_metadata(self) -> None:
        cases = (
            ("nightly", "nightly", "nightly", "nightly-233", "true"),
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


class ISOReleaseWorkflowTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        """Load the workflow's release shell step for direct regression tests."""
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        step = workflow.split(
            "      - name: Generate Release Notes & Tags from Template\n", 1
        )[1].split("\n      - name:", 1)[0]
        cls.script = textwrap.dedent(step.split("        run: |\n", 1)[1])

    def run_release_step(
        self, root: Path, *, prefix: str, release_id: str, version: str,
        prerelease: str,
    ) -> subprocess.CompletedProcess[str]:
        """Run release processing with isolated metadata and template files."""
        metadata = root / "staging/etc"
        metadata.mkdir(parents=True)
        values = {
            "arkana-build-number": "233\n",
            "arkana-release-prefix": f"{prefix}\n",
            "arkana-release-id": f"{release_id}\n",
            "arkana-release-version": version,
            "arkana-release-prerelease": f"{prerelease}\n",
        }
        for name, value in values.items():
            (metadata / name).write_text(value, encoding="utf-8")
        (root / "RELEASE_TEMPLATE.md").write_text(
            "# RELEASE_NAME\nRelease: RELEASE_NAME\n", encoding="utf-8"
        )
        github_env = root / "github-env"
        environment = os.environ.copy()
        environment["GITHUB_ENV"] = str(github_env)
        return subprocess.run(
            [
                "bash",
                "--noprofile",
                "--norc",
                "-e",
                "-o",
                "pipefail",
                "-c",
                self.script,
            ],
            cwd=root,
            env=environment,
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    def test_valid_release_metadata_renders_template_literally(self) -> None:
        """Accept supported labels and replace template placeholders literally."""
        cases = (
            ("nightly", "nightly", "nightly-233", "true"),
            ("r1-a1", "1.0 (alpha 1)", "v1.0-alpha1-build-233", "true"),
            ("r1-b1", "1.0 (beta 1)", "v1.0-beta1-build-233", "true"),
            ("r1-1", "1.0", "v1.0-build-233", "false"),
        )
        for prefix, version, release_id, prerelease in cases:
            with self.subTest(prefix=prefix), tempfile.TemporaryDirectory(
                prefix="arkana-iso-release-"
            ) as temporary:
                root = Path(temporary)
                result = self.run_release_step(
                    root,
                    prefix=prefix,
                    release_id=release_id,
                    version=f"{version}\n",
                    prerelease=prerelease,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                expected_name = f"arkanaOS {version} build 233"
                self.assertEqual(
                    (root / "RELEASE_TEMPLATE.md").read_text(encoding="utf-8"),
                    f"# {expected_name}\nRelease: {expected_name}\n",
                )
                self.assertIn(
                    f"RELEASE_ID={release_id}\n",
                    (root / "github-env").read_text(encoding="utf-8"),
                )

    def test_release_version_cannot_inject_commands_into_template_processing(self) -> None:
        """Reject a multiline version that could add a sed file-write command."""
        with tempfile.TemporaryDirectory(prefix="arkana-iso-release-") as temporary:
            root = Path(temporary)
            marker = root / "injected-file"
            # With the old sed expression, these newlines create a sed `w`
            # command that writes the template's pattern space to this path.
            malicious_version = f"1.0/\nw {marker}\n#\n"
            result = self.run_release_step(
                root,
                prefix="r1-a1",
                release_id="v1.0-alpha1-build-233",
                version=malicious_version,
                prerelease="true",
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Release metadata does not match", result.stderr)
            self.assertFalse(marker.exists())
            self.assertEqual(
                (root / "RELEASE_TEMPLATE.md").read_text(encoding="utf-8"),
                "# RELEASE_NAME\nRelease: RELEASE_NAME\n",
            )


if __name__ == "__main__":
    unittest.main()
