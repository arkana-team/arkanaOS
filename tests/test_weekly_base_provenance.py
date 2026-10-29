"""Verify persistent release ISO metadata and its scheduled-build provenance."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import os
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
SCRIPT_PATH = REPOSITORY / "scripts/verify-weekly-base-provenance.py"
SPEC = importlib.util.spec_from_file_location("weekly_base_provenance", SCRIPT_PATH)
assert SPEC is not None and SPEC.loader is not None
PROVENANCE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PROVENANCE)


class WeeklyBaseProvenanceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.sha = "a" * 40
        self.marker = (
            "arkup-client=/usr/bin/arkup\n"
            "base-sequence=1\n"
            "system-update=1\n"
            "source-run-id=12345\n"
            f"source-sha={self.sha}\n"
            "build-number=233\n"
        )
        self.run = {
            "id": 12345,
            "workflow_id": 678,
            "repository": {"full_name": "arkana-team/arkanaOS"},
            "head_repository": {"full_name": "arkana-team/arkanaOS"},
            "head_branch": "main",
            "head_sha": self.sha,
            "event": "schedule",
            "status": "completed",
            "conclusion": "success",
        }
        self.release = {
            "tag_name": "nightly-233",
            "draft": False,
            "published_at": "2026-10-27T03:00:00Z",
            "assets": [
                {
                    "id": 987,
                    "name": "arkana.iso",
                    "size": 1024,
                    "digest": "sha256:" + "1" * 64,
                },
                {
                    "id": 456,
                    "name": "arkanaOS-update-client-system-update.txt",
                    "size": len(self.marker.encode()),
                    "digest": "sha256:" + hashlib.sha256(self.marker.encode()).hexdigest(),
                },
            ],
        }
        self.arguments = {
            "release_tag": "nightly-233",
            "tag_sha": self.sha,
            "marker_text": self.marker,
            "run": self.run,
            "release_payload": self.release,
            "repository": "arkana-team/arkanaOS",
            "default_branch": "main",
            "workflow_id": "678",
        }

    def verify(self, **overrides: object) -> dict[str, str]:
        arguments = self.arguments | overrides
        return PROVENANCE.verify_base_provenance(**arguments)

    def test_accepts_matching_successful_run_and_persistent_release_iso(self) -> None:
        self.assertEqual(
            self.verify(),
            {
                "run_id": "12345",
                "release_tag": "nightly-233",
                "iso_asset_id": "987",
                "iso_asset_size": "1024",
                "iso_digest": "sha256:" + "1" * 64,
                "marker_asset_id": "456",
                "marker_asset_size": str(len(self.marker.encode())),
                "marker_digest": "sha256:" + hashlib.sha256(self.marker.encode()).hexdigest(),
                "build_number": "233",
                "source_sha": self.sha,
            },
        )

    def test_supports_versioned_release_tags(self) -> None:
        self.assertEqual(PROVENANCE.release_build_number("v1.0-alpha1-build-233"), "233")

    def test_rejects_release_tag_or_marker_build_mismatch(self) -> None:
        with self.assertRaises(PROVENANCE.ProvenanceError):
            self.verify(tag_sha="b" * 40)
        with self.assertRaises(PROVENANCE.ProvenanceError):
            self.verify(release_tag="nightly-234")

    def test_rejects_untrusted_or_incomplete_markers(self) -> None:
        invalid_markers = [
            self.marker.replace("source-sha=", "source-sha=bad"),
            self.marker.replace("source-run-id=12345\n", ""),
            self.marker + "source-run-id=54321\n",
            self.marker.replace("system-update=1", "system-update=0"),
            self.marker.replace("build-number=233", "build-number=bad"),
        ]
        for marker in invalid_markers:
            with (
                self.subTest(marker=marker),
                self.assertRaises(PROVENANCE.ProvenanceError),
            ):
                self.verify(marker_text=marker)

    def test_rejects_runs_from_other_repositories_or_workflows(self) -> None:
        for field, value in (
            ("id", 999),
            ("workflow_id", 999),
            ("repository", {"full_name": "fork/arkanaOS"}),
            ("head_repository", {"full_name": "fork/arkanaOS"}),
        ):
            run = copy.deepcopy(self.run)
            run[field] = value
            with (
                self.subTest(field=field),
                self.assertRaises(PROVENANCE.ProvenanceError),
            ):
                self.verify(run=run)

    def test_rejects_runs_without_matching_default_branch_provenance(self) -> None:
        for field, value in (
            ("head_branch", "feature"),
            ("head_sha", "b" * 40),
            ("event", "pull_request"),
            ("status", "in_progress"),
            ("conclusion", "failure"),
        ):
            run = copy.deepcopy(self.run)
            run[field] = value
            with (
                self.subTest(field=field),
                self.assertRaises(PROVENANCE.ProvenanceError),
            ):
                self.verify(run=run)

    def test_rejects_missing_ambiguous_or_invalid_persistent_iso_assets(self) -> None:
        iso = self.release["assets"][0]
        for assets in (
            [self.release["assets"][1]],
            self.release["assets"] + [iso],
            [{**iso, "size": 0}, self.release["assets"][1]],
            [{**iso, "id": 0}, self.release["assets"][1]],
            [{**iso, "digest": "sha1:" + "1" * 40}, self.release["assets"][1]],
            [{**iso, "size": PROVENANCE.MAX_ISO_SIZE + 1}, self.release["assets"][1]],
        ):
            with (
                self.subTest(assets=assets),
                self.assertRaises(PROVENANCE.ProvenanceError),
            ):
                self.verify(release_payload={**self.release, "assets": assets})

    def test_rejects_unsupported_release_tags(self) -> None:
        with self.assertRaises(PROVENANCE.ProvenanceError):
            self.verify(release_tag="../../attacker")


class WeeklyBasePreflightTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory(prefix="arkana-weekly-preflight-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.sha = "a" * 40
        self.marker = (
            "arkup-client=/usr/bin/arkup\n"
            "base-sequence=1\n"
            "system-update=1\n"
            "source-run-id=12345\n"
            f"source-sha={self.sha}\n"
            "build-number=233\n"
        )
        self.weekly_sha = "b" * 40
        self.weekly_marker = self.marker.replace(
            "source-run-id=12345\n", "source-run-id=12344\n"
        ).replace(self.sha, self.weekly_sha).replace("build-number=233", "build-number=220")
        self.write_json(
            "releases.json",
            [
                {
                    "tag_name": "weekly-220",
                    "published_at": "2026-10-20T03:00:00Z",
                    "draft": False,
                    "assets": [
                        {"name": "arkana.iso"},
                        {"name": "weekly-220.aup"},
                        {"name": "arkanaOS-update-client-system-update.txt"},
                    ],
                },
                {
                    "tag_name": "nightly-233",
                    "published_at": "2026-10-27T03:00:00Z",
                    "draft": False,
                    "assets": [
                    {"name": "arkana.iso"},
                    {"name": "nightly-233.aup"},
                    {"name": "arkanaOS-update-client-system-update.txt"},
                    ],
                }
            ],
        )
        self.write_json(
            "release.json",
            {
                "tag_name": "nightly-233",
                "draft": False,
                "published_at": "2026-10-27T03:00:00Z",
                "assets": [
                    {
                        "id": 987,
                        "name": "arkana.iso",
                        "size": 1024,
                        "digest": "sha256:" + "1" * 64,
                    },
                    {
                        "id": 456,
                        "name": "arkanaOS-update-client-system-update.txt",
                        "size": len(self.marker.encode()),
                        "digest": "sha256:" + hashlib.sha256(self.marker.encode()).hexdigest(),
                    }
                ]
            },
        )
        self.write_json(
            "weekly-release.json",
            {
                "tag_name": "weekly-220",
                "draft": False,
                "published_at": "2026-10-20T03:00:00Z",
                "assets": [
                    {
                        "id": 986,
                        "name": "arkana.iso",
                        "size": 1024,
                        "digest": "sha256:" + "2" * 64,
                    },
                    {
                        "id": 457,
                        "name": "arkanaOS-update-client-system-update.txt",
                        "size": len(self.weekly_marker.encode()),
                        "digest": "sha256:" + hashlib.sha256(self.weekly_marker.encode()).hexdigest(),
                    },
                ],
            },
        )
        self.write_json(
            "run.json",
            {
                "id": 12345,
                "workflow_id": 678,
                "repository": {"full_name": "arkana-team/arkanaOS"},
                "head_repository": {"full_name": "arkana-team/arkanaOS"},
                "head_branch": "main",
                "head_sha": self.sha,
                "event": "schedule",
                "status": "completed",
                "conclusion": "success",
            },
        )
        self.write_json(
            "weekly-run.json",
            {
                "id": 12344,
                "workflow_id": 678,
                "repository": {"full_name": "arkana-team/arkanaOS"},
                "head_repository": {"full_name": "arkana-team/arkanaOS"},
                "head_branch": "main",
                "head_sha": self.weekly_sha,
                "event": "schedule",
                "status": "completed",
                "conclusion": "success",
            },
        )
        (self.root / "marker.txt").write_text(self.marker, encoding="utf-8")
        (self.root / "weekly-marker.txt").write_text(self.weekly_marker, encoding="utf-8")
        gh = self.bin / "gh"
        gh.write_text(
            textwrap.dedent(
                """\
                #!/usr/bin/env python3
                import os, pathlib, sys
                args = sys.argv[1:]
                endpoint = next((arg for arg in args if arg.startswith('repos/')), '')
                root = pathlib.Path(os.environ['FIXTURE_ROOT'])
                if endpoint == 'repos/arkana-team/arkanaOS/releases?per_page=100':
                    sys.stdout.write((root / 'releases.json').read_text())
                elif endpoint == 'repos/arkana-team/arkanaOS/releases/tags/nightly-233':
                    sys.stdout.write((root / 'release.json').read_text())
                elif endpoint == 'repos/arkana-team/arkanaOS/releases/tags/weekly-220':
                    sys.stdout.write((root / 'weekly-release.json').read_text())
                elif endpoint in ('repos/arkana-team/arkanaOS/releases/assets/456', 'repos/arkana-team/arkanaOS/releases/assets/457'):
                    marker = 'weekly-marker.txt' if endpoint.endswith('/457') else 'marker.txt'
                    sys.stdout.buffer.write((root / marker).read_bytes())
                elif endpoint == 'repos/arkana-team/arkanaOS/actions/workflows/00_run_all.yml':
                    print('678')
                elif endpoint == 'repos/arkana-team/arkanaOS/actions/runs/12345':
                    sys.stdout.write((root / 'run.json').read_text())
                elif endpoint == 'repos/arkana-team/arkanaOS/actions/runs/12344':
                    sys.stdout.write((root / 'weekly-run.json').read_text())
                elif endpoint == 'repos/arkana-team/arkanaOS/commits/nightly-233':
                    print(os.environ['FIXTURE_SHA'])
                elif endpoint == 'repos/arkana-team/arkanaOS/commits/weekly-220':
                    print(os.environ['FIXTURE_WEEKLY_SHA'])
                else:
                    print('unexpected gh api endpoint: ' + endpoint, file=sys.stderr)
                    sys.exit(2)
                """
            ),
            encoding="utf-8",
        )
        gh.chmod(0o755)
        workflow = (REPOSITORY / ".github/workflows/00_run_all.yml").read_text(
            encoding="utf-8"
        )
        step = workflow.split(
            "      - name: Verify persistent release ISOs as update bases\n",
            1,
        )[1].split("\n  stage1:", 1)[0]
        self.script = textwrap.dedent(step.split("        run: |\n", 1)[1])
        self.output = self.root / "github-output"
        self.environment = {
            **os.environ,
            "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
            "FIXTURE_ROOT": str(self.root),
            "FIXTURE_SHA": self.sha,
            "FIXTURE_WEEKLY_SHA": self.weekly_sha,
            "RUNNER_TEMP": str(self.root),
            "GITHUB_OUTPUT": str(self.output),
            "GITHUB_REPOSITORY": "arkana-team/arkanaOS",
            "DEFAULT_BRANCH": "main",
            "UPDATE_BASE_CHANNEL": "nightly",
            "GH_TOKEN": "test-token",
        }
        self.environment.pop("BASH_ENV", None)

    def write_json(self, name: str, value: object) -> None:
        (self.root / name).write_text(json.dumps(value), encoding="utf-8")

    def execute(self) -> subprocess.CompletedProcess[str]:
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
            cwd=REPOSITORY,
            env=self.environment,
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    def test_preflight_exports_verified_persistent_release_identity(self) -> None:
        result = self.execute()
        self.assertEqual(result.returncode, 0, result.stderr)
        [output] = self.output.read_text(encoding="utf-8").splitlines()
        self.assertTrue(output.startswith("update_bases_json="))
        bases = json.loads(output.partition("=")[2])
        self.assertEqual(len(bases), 1)
        self.assertEqual(bases[0]["release_tag"], "nightly-233")
        self.assertEqual(bases[0]["iso_asset_id"], "987")
        self.assertEqual(bases[0]["iso_digest"], "sha256:" + "1" * 64)
        self.assertEqual(bases[0]["build_number"], "233")
        self.assertEqual(bases[0]["source_sha"], self.sha)

    def test_preflight_rejects_a_replaced_release_marker(self) -> None:
        tampered_marker = self.marker.replace(self.sha, "b" * 40)
        (self.root / "marker.txt").write_text(tampered_marker, encoding="utf-8")
        result = self.execute()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.output.exists())

    def test_monday_preflight_exports_both_verified_update_paths(self) -> None:
        self.environment["UPDATE_BASE_CHANNEL"] = "weekly"
        result = self.execute()
        self.assertEqual(result.returncode, 0, result.stderr)
        [output] = self.output.read_text(encoding="utf-8").splitlines()
        bases = json.loads(output.partition("=")[2])
        self.assertEqual(
            [base["release_tag"] for base in bases],
            ["weekly-220", "nightly-233"],
        )
        self.assertEqual(
            [base["build_number"] for base in bases], ["220", "233"]
        )


if __name__ == "__main__":
    unittest.main()
