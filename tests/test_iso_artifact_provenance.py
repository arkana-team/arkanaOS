"""Exercise artifact consumers' actual shell with synthetic API responses."""

import io
import json
import os
import subprocess
import tarfile
import tempfile
import textwrap
import unittest
from pathlib import Path


REPOSITORY = Path(__file__).resolve().parents[1]


class ArtifactProvenanceChecks:
    def step(self, name):
        content = self.workflow.read_text().split(f"      - name: {name}\n", 1)[1]
        return content.split("\n      - name:", 1)[0]

    def setUp(self):
        self.workflow = REPOSITORY / ".github/workflows" / self.workflow_name
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.workspace = self.root / "workspace"
        self.workspace.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        gh = self.bin / "gh"
        gh.write_text(textwrap.dedent("""\
            #!/usr/bin/env python3
            import os, pathlib, sys
            with open(os.environ['API_LOG'], 'a') as log:
                log.write(' '.join(sys.argv[1:]) + '\\n')
            if os.environ.get('FAIL_API') == 'yes':
                sys.exit(1)
            if sys.argv[1:] == ['api', 'repos/arkana-team/arkanaOS/actions/workflows/00_run_all.yml', '--jq', '.id']:
                print('123')
            elif sys.argv[1:] == ['api', 'repos/arkana-team/arkanaOS/actions/runs/456']:
                print(pathlib.Path(os.environ['RUN_JSON']).read_text())
            else:
                sys.exit(2)
            """))
        gh.chmod(0o755)
        # Extraction needs no root privileges for these synthetic files.
        sudo = self.bin / "sudo"
        sudo.write_text('#!/bin/sh\nexec "$@"\n')
        sudo.chmod(0o755)
        self.output = self.root / "output"
        self.api_log = self.root / "api.log"
        self.run_json = self.root / "run.json"
        self.run = {
            "id": 456,
            "workflow_id": 123,
            "repository": {"full_name": "arkana-team/arkanaOS"},
            "head_repository": {"full_name": "arkana-team/arkanaOS"},
            "head_branch": "main",
            "head_sha": "a" * 40,
            "event": "workflow_dispatch",
            "status": "completed",
            "conclusion": "success",
        }
        self.env = {
            **os.environ,
            "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
            "API_LOG": str(self.api_log),
            "RUN_JSON": str(self.run_json),
            "GITHUB_OUTPUT": str(self.output),
            "GITHUB_REPOSITORY": "arkana-team/arkanaOS",
            "GITHUB_EVENT_NAME": "workflow_dispatch",
            "GITHUB_REF": "refs/heads/main",
            "GITHUB_WORKFLOW_REF": f"arkana-team/arkanaOS/.github/workflows/{self.workflow_name}@refs/heads/main",
            "GITHUB_RUN_ID": "789",
            "GITHUB_SHA": "b" * 40,
            "DEFAULT_BRANCH": "main",
            "SOURCE_RUN_ID": "456",
            "RUNNER_TEMP": str(self.root),
        }
        # A host shell startup file must not replace the synthetic gh fixture.
        self.env.pop("BASH_ENV", None)

    def execute(self, name):
        self.run_json.write_text(json.dumps(self.run))
        script = textwrap.dedent(self.step(name).split("        run: |\n", 1)[1])
        return subprocess.run(
            ["bash", "-e", "-c", script], cwd=self.workspace, env=self.env,
            capture_output=True, text=True, timeout=10,
        )

    def test_verified_run_pins_both_checkout_and_download(self):
        result = self.execute(f"Verify Stage {self.stage} Source")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.output.read_text(), f"run_id=456\nsha={'a' * 40}\n")
        self.assertIn("ref: ${{ steps.source.outputs.sha }}", self.step("Checkout Repository"))
        download = self.step(f"Download Verified Stage {self.stage} Artifact")
        self.assertIn(f"name: arkana-stage{self.stage}", download)
        self.assertIn("run-id: ${{ steps.source.outputs.run_id }}", download)
        self.assertIn("github-token: ${{ secrets.GITHUB_TOKEN }}", download)
        self.assertIn("path: ${{ runner.temp }}/stage" + str(self.stage) + "-download", download)

    def test_current_pipeline_uses_only_its_own_artifact_and_revision(self):
        self.env["GITHUB_WORKFLOW_REF"] = self.env["GITHUB_WORKFLOW_REF"].replace(
            self.workflow_name, "00_run_all.yml"
        )
        self.env["SOURCE_RUN_ID"] = ""
        result = self.execute(f"Verify Stage {self.stage} Source")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.output.read_text(), f"run_id=789\nsha={'b' * 40}\n")
        self.assertFalse(self.api_log.exists())

    def test_rejects_untrusted_producer_metadata(self):
        invalid = {
            "id": [457, None],
            "workflow_id": [999, None],
            "repository": [{"full_name": "attacker/fork"}, None],
            "head_repository": [{"full_name": "attacker/fork"}, None],
            "head_branch": ["feature", None],
            "head_sha": ["main", "", None, "a" * 39],
            "event": ["pull_request", "pull_request_target", "push", "workflow_run"],
            "status": ["in_progress", "queued", None],
            "conclusion": ["failure", "cancelled", "skipped", None],
        }
        for field, values in invalid.items():
            original = self.run[field]
            for value in values:
                with self.subTest(field=field, value=value):
                    self.run[field] = value
                    result = self.execute(f"Verify Stage {self.stage} Source")
                    self.assertNotEqual(result.returncode, 0)
                    self.assertFalse(self.output.exists())
            self.run[field] = original

    def test_rejects_untrusted_consumers_and_invalid_run_ids_before_api(self):
        invalid = {
            "GITHUB_EVENT_NAME": ["pull_request", "pull_request_target", "workflow_run"],
            "GITHUB_REF": ["refs/heads/feature", "refs/tags/main"],
            "GITHUB_WORKFLOW_REF": [
                "arkana-team/arkanaOS/.github/workflows/spoof.yml@refs/heads/main",
                "attacker/fork/.github/workflows/00_run_all.yml@refs/heads/main",
            ],
            "SOURCE_RUN_ID": ["", "0", "-1", "456/../789", "456\nsha=main"],
        }
        for field, values in invalid.items():
            original = self.env[field]
            for value in values:
                with self.subTest(field=field, value=value):
                    self.env[field] = value
                    result = self.execute(f"Verify Stage {self.stage} Source")
                    self.assertNotEqual(result.returncode, 0)
                    self.assertFalse(self.output.exists())
                    self.assertFalse(self.api_log.exists())
            self.env[field] = original

    def test_api_failure_stops_authorization(self):
        self.env["FAIL_API"] = "yes"
        result = self.execute(f"Verify Stage {self.stage} Source")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.output.exists())

    def archive(self, extra=()):
        download = self.root / f"stage{self.stage}-download"
        download.mkdir()
        with tarfile.open(download / f"arkana-stage{self.stage}.tar", "w") as archive:
            for name in ["staging", "src"]:
                member = tarfile.TarInfo(name)
                member.type = tarfile.DIRTYPE
                member.mode = 0o755
                archive.addfile(member)
            for name in ["staging/build-number", "src/source"]:
                member = tarfile.TarInfo(name)
                member.size = 4
                archive.addfile(member, io.BytesIO(b"data"))
            for member, data in extra:
                archive.addfile(member, io.BytesIO(data) if data else None)

    def test_extraction_imports_only_expected_roots_and_preserves_runtime_links(self):
        self.workspace.joinpath("Dockerfile").write_text("trusted")
        self.workspace.joinpath("arkanas").mkdir()
        self.workspace.joinpath("arkanas/build.mk").write_text("trusted")
        unrelated = []
        for name in ["Dockerfile", "arkanas/build.mk"]:
            member = tarfile.TarInfo(name)
            member.size = 4
            unrelated.append((member, b"evil"))
        link = tarfile.TarInfo("staging/runtime-link")
        link.type = tarfile.SYMTYPE
        link.linkname = "/dev/null"
        self.archive([*unrelated, (link, None)])
        result = self.execute(f"Unarchive Stage {self.stage}")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.workspace.joinpath("Dockerfile").read_text(), "trusted")
        self.assertEqual(self.workspace.joinpath("arkanas/build.mk").read_text(), "trusted")
        self.assertEqual(self.workspace.joinpath("src/source").read_text(), "data")
        self.assertEqual(os.readlink(self.workspace / "staging/runtime-link"), "/dev/null")

    def test_extraction_rejects_existing_roots_without_replacing_them(self):
        self.archive()
        for member in ["staging", "src"]:
            for kind in ["directory", "symlink"]:
                with self.subTest(member=member, kind=kind):
                    destination = self.workspace / member
                    if kind == "directory":
                        destination.mkdir()
                        (destination / "trusted").write_text("keep")
                    else:
                        destination.symlink_to(self.root / "missing")
                    result = self.execute(f"Unarchive Stage {self.stage}")
                    self.assertNotEqual(result.returncode, 0)
                    if kind == "directory":
                        self.assertEqual((destination / "trusted").read_text(), "keep")
                        (destination / "trusted").unlink()
                        destination.rmdir()
                    else:
                        self.assertTrue(destination.is_symlink())
                        destination.unlink()

    def test_extraction_rejects_parent_traversal_and_symlink_writes(self):
        for attack in ["traversal", "symlink", "hardlink", "root-link"]:
            with self.subTest(attack=attack):
                outside = self.root / "outside"
                outside.mkdir(exist_ok=True)
                if attack == "traversal":
                    member = tarfile.TarInfo("staging/../../outside/payload")
                    member.size = 4
                    extra = [(member, b"evil")]
                else:
                    member = tarfile.TarInfo("staging" if attack == "root-link" else "staging/link")
                    member.type = tarfile.LNKTYPE if attack == "hardlink" else tarfile.SYMTYPE
                    member.linkname = str(outside / "payload") if attack == "hardlink" else str(outside)
                    extra = [(member, None)]
                    if attack == "symlink":
                        payload = tarfile.TarInfo("staging/link/payload")
                        payload.size = 4
                        extra.append((payload, b"evil"))
                self.archive(extra)
                result = self.execute(f"Unarchive Stage {self.stage}")
                self.assertNotEqual(result.returncode, 0)
                self.assertFalse((outside / "payload").exists())
                self.assertFalse((self.workspace / "staging").exists())
                (self.root / f"stage{self.stage}-download/arkana-stage{self.stage}.tar").unlink()
                (self.root / f"stage{self.stage}-download").rmdir()


class Stage1ArtifactProvenanceTests(ArtifactProvenanceChecks, unittest.TestCase):
    stage = 1
    workflow_name = "02_stage2_toolchain.yml"


class Stage2ArtifactProvenanceTests(ArtifactProvenanceChecks, unittest.TestCase):
    stage = 2
    workflow_name = "03_stage3_graphics.yml"


class ISOArtifactProvenanceTests(ArtifactProvenanceChecks, unittest.TestCase):
    stage = 3
    workflow_name = "04_stage4_iso.yml"


if __name__ == "__main__":
    unittest.main()
