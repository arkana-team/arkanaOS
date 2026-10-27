"""Exercise build.sh mode dispatch without starting real containers."""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "build.sh"


class BuildModeTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="arkana-builder-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.project = self.root / "project"
        self.project.mkdir()
        shutil.copy2(SCRIPT, self.project / "build.sh")

        self.bin_dir = self.root / "bin"
        self.bin_dir.mkdir()
        self.docker_log = self.root / "docker.log"
        self.update_log = self.root / "update.json"
        docker = self.bin_dir / "docker"
        docker.write_text(
            "#!/usr/bin/env bash\n"
            "set -euo pipefail\n"
            'printf \'%s\\n\' "$*" >> "$DOCKER_LOG"\n'
            'if [[ "${1:-}" == run ]]; then\n'
            '  mkdir -p "$PROJECT_DIR/output/iso-root"\n'
            "  printf 'arkanaOS ISO root\\n' > \"$PROJECT_DIR/output/iso-root/.arkana-iso-root\"\n"
            "  printf 'iso\\n' > \"$PROJECT_DIR/output/arkana.iso\"\n"
            "fi\n",
            encoding="utf-8",
        )
        docker.chmod(0o755)

        update = self.project / "build-update.sh"
        update.write_text(
            "#!/usr/bin/env python3\n"
            "import json, os, sys\n"
            "from pathlib import Path\n"
            "Path(os.environ['UPDATE_LOG']).write_text(json.dumps(sys.argv[1:]))\n",
            encoding="utf-8",
        )
        update.chmod(0o755)

        self.env = os.environ.copy()
        self.env.update(
            {
                "PATH": f"{self.bin_dir}{os.pathsep}{self.env['PATH']}",
                "PROJECT_DIR": str(self.project),
                "DOCKER_LOG": str(self.docker_log),
                "UPDATE_LOG": str(self.update_log),
            }
        )

    def run_builder(
        self, *arguments: str, cwd: Path | None = None
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [str(self.project / "build.sh"), *arguments],
            cwd=cwd or self.project,
            env=self.env,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_help_documents_all_modes(self) -> None:
        result = self.run_builder("--help")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("--iso", result.stdout)
        self.assertIn("--update", result.stdout)
        self.assertIn("--both", result.stdout)

    def test_unknown_mode_fails_before_building(self) -> None:
        result = self.run_builder("--surprise")
        self.assertEqual(result.returncode, 2)
        self.assertFalse(self.docker_log.exists())

    def test_no_mode_keeps_iso_as_the_default(self) -> None:
        result = self.run_builder()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        docker_command = self.docker_log.read_text()
        self.assertIn("-t arkana-builder .", docker_command)
        run_command = next(
            line for line in docker_command.splitlines() if line.startswith("run ")
        )
        self.assertIn("run --rm --init", run_command)
        self.assertNotRegex(run_command, r"(^|\s)(?:-it|-t|--tty)(?:\s|$)")
        self.assertFalse(self.update_log.exists())

    def test_update_mode_delegates_all_options(self) -> None:
        arguments = (
            "--base-root",
            "/tmp/base root",
            "--target-root",
            "/tmp/target root",
            "--signing-key",
            "/tmp/release.key",
        )
        result = self.run_builder("--update", *arguments)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(self.update_log.read_text()), list(arguments))
        self.assertFalse(self.docker_log.exists())

    def test_both_builds_iso_then_uses_its_root_as_update_target(self) -> None:
        base_root = self.root / "base root"
        base_root.mkdir()
        signing_key = self.root / "release key"
        public_key = self.root / "release public key"
        signing_key.write_text("private", encoding="utf-8")
        public_key.write_text("public", encoding="utf-8")

        result = self.run_builder(
            "--both",
            "--base-root",
            "base root",
            "--signing-key",
            "release key",
            "--public-key",
            "release public key",
            "--description",
            "weekly developer build",
            cwd=self.root,
        )
        docker_output = (
            self.docker_log.read_text() if self.docker_log.exists() else "missing"
        )
        self.assertEqual(
            result.returncode, 0, result.stdout + result.stderr + docker_output
        )
        self.assertIn("-t arkana-builder .", self.docker_log.read_text())
        update_args = json.loads(self.update_log.read_text())
        self.assertEqual(
            update_args[update_args.index("--base-root") + 1], str(base_root)
        )
        self.assertEqual(
            update_args[update_args.index("--target-root") + 1],
            str(self.project / "output/iso-root"),
        )
        self.assertIn("weekly developer build", update_args)

    def test_both_requires_update_inputs_before_building(self) -> None:
        result = self.run_builder("--both", "--base-root", "/tmp/base")
        self.assertEqual(result.returncode, 2)
        self.assertFalse(self.docker_log.exists())


class WorkflowSecurityTests(unittest.TestCase):
    def test_source_checkouts_do_not_persist_github_credentials(self) -> None:
        workflow = (
            Path(__file__).resolve().parents[1]
            / ".github/workflows/update-builder-tests.yml"
        )
        contents = workflow.read_text(encoding="utf-8")
        blocks = re.split(r"(?m)^      - ", contents)
        checkouts = [
            block for block in blocks if block.startswith("name: Check out source\n")
        ]

        self.assertEqual(len(checkouts), 2)
        for block in checkouts:
            self.assertRegex(block, r"(?m)^        uses: actions/checkout@")
            self.assertRegex(block, r"(?m)^          persist-credentials: false$")

    def test_integration_test_changes_trigger_the_workflow(self) -> None:
        workflow = (
            Path(__file__).resolve().parents[1]
            / ".github/workflows/update-builder-tests.yml"
        )
        contents = workflow.read_text(encoding="utf-8")

        self.assertEqual(
            contents.count('      - "tests/test_update_builder_integration.py"'), 2
        )

    def test_update_builder_can_read_restricted_iso_files_without_mode_changes(
        self,
    ) -> None:
        script = Path(__file__).resolve().parents[1] / "build-update.sh"
        contents = script.read_text(encoding="utf-8")

        self.assertIn('  --user "$(id -u):$(id -g)"', contents)
        self.assertIn("  --cap-drop ALL", contents)
        self.assertIn("  --cap-add DAC_READ_SEARCH", contents)
        self.assertIn("src=$TARGET_ROOT,dst=/inputs/target,readonly", contents)
        self.assertNotRegex(contents, r"(?m)^\s*(?:chmod|chown)\b")
        workflow = (
            Path(__file__).resolve().parents[1]
            / ".github/workflows/update-builder-tests.yml"
        ).read_text(encoding="utf-8")
        self.assertIn("Verify non-root access to root-owned inputs", workflow)
        self.assertIn("sudo chmod 0600", workflow)
        self.assertIn("stat -c '%u:%g:%a'", workflow)


class BuildNumberSeedTests(unittest.TestCase):
    def test_legacy_nightly_tag_advances_build_counter(self) -> None:
        script = Path(__file__).resolve().parents[1] / "scripts/seed-build-number.py"
        with tempfile.TemporaryDirectory(prefix="arkana-build-seed-test-") as temporary:
            build_file = Path(temporary) / ".buildnum"
            build_file.write_text("907\n", encoding="ascii")
            result = subprocess.run(
                [sys.executable, str(script), "--build-file", str(build_file)],
                input="nightly-build-912\n",
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(build_file.read_text(encoding="ascii"), "912\n")
            self.assertIn("latest-published=912", result.stdout)


if __name__ == "__main__":
    unittest.main()
