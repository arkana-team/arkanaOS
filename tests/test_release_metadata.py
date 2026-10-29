#!/usr/bin/env python3
"""Exercise release metadata generation using isolated build-number files."""

from __future__ import annotations

import json
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
RUN_ALL_WORKFLOW = REPOSITORY / ".github/workflows/00_run_all.yml"
RELEASE_TEMPLATE = REPOSITORY / "RELEASE_TEMPLATE.md"
WEEKLY_BASE_SELECTOR = REPOSITORY / "scripts/select-weekly-update-base.py"


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
            ("weekly", "weekly", "weekly", "weekly-233", "true"),
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
        prerelease: str, event_name: str = "workflow_dispatch",
        update_bases_json: str | None = None,
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
        shutil.copy2(RELEASE_TEMPLATE, root / "RELEASE_TEMPLATE.md")
        github_env = root / "github-env"
        environment = os.environ.copy()
        environment["GITHUB_ENV"] = str(github_env)
        environment["GITHUB_EVENT_NAME"] = event_name
        if update_bases_json is not None:
            environment["UPDATE_BASES_JSON"] = update_bases_json
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
            (
                "nightly", "nightly", "nightly-233", "true", "Nightly",
                "Developer build for testing and development only. Supported for 7 days.",
            ),
            (
                "weekly", "weekly", "weekly-233", "true", "Weekly",
                "Weekly developer build for testing and development only. Supported for 7 days.",
            ),
            (
                "r1-a1", "1.0 (alpha 1)", "v1.0-alpha1-build-233", "true", "Alpha",
                "Early pre-release for testing and development. Supported for 2 weeks.",
            ),
            (
                "r1-b1", "1.0 (beta 1)", "v1.0-beta1-build-233", "true", "Beta",
                "Pre-release for broader testing. Supported for 7 weeks.",
            ),
            (
                "r1-1", "1.0", "v1.0-build-233", "false", "Stable",
                "Stable release. Supported for 10 months.",
            ),
        )
        for prefix, version, release_id, prerelease, channel, status in cases:
            with self.subTest(prefix=prefix), tempfile.TemporaryDirectory(
                prefix="arkana-iso-release-"
            ) as temporary:
                root = Path(temporary)
                event_name = (
                    "schedule" if prefix == "weekly" else "workflow_dispatch"
                )
                result = self.run_release_step(
                    root,
                    prefix=prefix,
                    release_id=release_id,
                    version=f"{version}\n",
                    prerelease=prerelease,
                    event_name=event_name,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                expected_name = f"arkanaOS {version} build 233"
                if event_name == "schedule" and prefix == "weekly":
                    update_assets = (
                        "This is the initial scheduled ISO bootstrap. It includes the verification public key "
                        "and seeds the signed .aup update path; update packages begin with the next scheduled release."
                    )
                    update_guidance = (
                        "No .aup package is attached because there is no earlier update-capable release to target. "
                        "After the next scheduled release includes its update package, trust the verification key "
                        "once on the installed system:\n\n```sh\nsudo arkup trust ./arkanaOS-update-signing.pub\n```"
                    )
                else:
                    update_assets = "This manually triggered release includes the bootable ISO only."
                    update_guidance = "No signed .aup update package is attached to a manually triggered release."
                expected_template = (
                    RELEASE_TEMPLATE.read_text(encoding="utf-8")
                    .replace("@@RELEASE_CHANNEL@@", channel)
                    .replace("@@RELEASE_NAME@@", expected_name)
                    .replace("@@RELEASE_STATUS@@", status)
                    .replace("@@RELEASE_UPDATE_ASSETS@@", update_assets)
                    .replace("@@RELEASE_UPDATE_GUIDANCE@@", update_guidance)
                )
                self.assertEqual(
                    (root / "RELEASE_TEMPLATE.md").read_text(encoding="utf-8"),
                    expected_template,
                )
                if event_name == "schedule":
                    self.assertIn(
                        "sudo arkup trust ./arkanaOS-update-signing.pub",
                        expected_template,
                    )
                    self.assertNotIn("sudo arkup apply", expected_template)
                else:
                    self.assertNotIn("sudo arkup trust", expected_template)
                    self.assertNotIn("sudo arkup apply", expected_template)
                self.assertIn(
                    f"RELEASE_ID={release_id}\n",
                    (root / "github-env").read_text(encoding="utf-8"),
                )
                self.assertIn(
                    f"RELEASE_NAME={expected_name}\n",
                    (root / "github-env").read_text(encoding="utf-8"),
                )

    def test_scheduled_release_with_a_base_documents_aup_assets(self) -> None:
        with tempfile.TemporaryDirectory(prefix="arkana-iso-release-") as temporary:
            root = Path(temporary)
            result = self.run_release_step(
                root,
                prefix="nightly",
                release_id="nightly-233",
                version="nightly\n",
                prerelease="true",
                event_name="schedule",
                update_bases_json='["nightly-232"]',
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            rendered = (root / "RELEASE_TEMPLATE.md").read_text(encoding="utf-8")
            self.assertIn("signed arkup .aup update package", rendered)
            self.assertIn("Each update package filename includes from-build-N", rendered)
            self.assertIn("Sunday's nightly build", rendered)
            self.assertIn("sudo arkup trust ./arkanaOS-update-signing.pub", rendered)
            self.assertIn("sudo arkup apply ./path/to/update.aup", rendered)
            self.assertNotIn("@@RELEASE_", rendered)

    def test_weekly_release_label_is_rejected_for_manual_dispatch(self) -> None:
        with tempfile.TemporaryDirectory(prefix="arkana-iso-release-") as temporary:
            root = Path(temporary)
            result = self.run_release_step(
                root,
                prefix="weekly",
                release_id="weekly-233",
                version="weekly",
                prerelease="true",
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("reserved for the Monday schedule", result.stderr)

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
                RELEASE_TEMPLATE.read_text(encoding="utf-8"),
            )



class WeeklyUpdateBaseSelectionTests(unittest.TestCase):
    @staticmethod
    def release(tag: str, published_at: str, *assets: str, draft: bool = False) -> dict:
        return {
            "tag_name": tag,
            "published_at": published_at,
            "draft": draft,
            "assets": [{"name": name} for name in assets],
        }

    def select(
        self,
        releases: list[dict],
        *arguments: str,
        channel: str = "nightly",
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(WEEKLY_BASE_SELECTOR), "--channel", channel, *arguments],
            input=json.dumps(releases),
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )

    @staticmethod
    def selected_tags(result: subprocess.CompletedProcess[str]) -> list[str]:
        return json.loads(result.stdout)

    def test_latest_scheduled_update_release_wins_over_older_weekly(self) -> None:
        releases = [
            self.release(
                "weekly-230",
                "2026-10-19T03:00:00Z",
                "arkana.iso",
                "arkanaos-weekly-old.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
            self.release(
                "nightly-233",
                "2026-10-25T03:00:00Z",
                "arkana.iso",
                "arkanaos-nightly-update.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
            self.release(
                "weekly-231",
                "2026-10-20T03:00:00Z",
                "arkana.iso",
                "arkanaos-weekly-latest.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
            self.release(
                "weekly-234",
                "2026-10-27T03:00:00Z",
                "arkana.iso",
                "draft.aup",
                draft=True,
            ),
        ]
        result = self.select(releases)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.selected_tags(result), ["nightly-233"])

    def test_weekly_release_keeps_previous_weekly_and_sunday_nightly_paths(self) -> None:
        releases = [
            self.release(
                "weekly-230",
                "2026-10-19T03:00:00Z",
                "arkana.iso",
                "weekly-230.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
            self.release(
                "nightly-233",
                "2026-10-25T03:00:00Z",
                "arkana.iso",
                "nightly-233.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
        ]
        result = self.select(releases, channel="weekly")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.selected_tags(result), ["weekly-230", "nightly-233"])

    def test_nightly_uses_newer_weekly_as_base_after_monday(self) -> None:
        releases = [
            self.release(
                "nightly-233",
                "2026-10-25T03:00:00Z",
                "arkana.iso",
                "nightly-233.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
            self.release(
                "weekly-234",
                "2026-10-26T03:00:00Z",
                "arkana.iso",
                "weekly-234.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
        ]
        result = self.select(releases, channel="nightly")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.selected_tags(result), ["weekly-234"])

    def test_alpha_and_beta_release_tags_are_eligible_as_update_bases(self) -> None:
        for tag, published_at in (
            ("v1.0-alpha1-build-233", "2026-10-28T03:00:00Z"),
            ("v1.0-beta1-build-240", "2026-10-29T03:00:00Z"),
        ):
            with self.subTest(tag=tag):
                result = self.select(
                    [
                        self.release(
                            tag,
                            published_at,
                            "arkana.iso",
                            "arkanaOS-update-client-system-update.txt",
                        )
                    ]
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.selected_tags(result), [tag])

    def test_weekly_without_arkup_marker_is_skipped(self) -> None:
        releases = [
            self.release(
                "nightly-230",
                "2026-10-19T03:00:00Z",
                "arkana.iso",
                "valid.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
            self.release("nightly-231", "2026-10-26T03:00:00Z", "arkana.iso", "incomplete.aup"),
        ]
        result = self.select(releases)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.selected_tags(result), ["nightly-230"])

    def test_base_sequence_only_marker_cannot_qualify_as_a_system_update_client(self) -> None:
        releases = [
            self.release(
                "nightly-240",
                "2026-10-25T03:00:00Z",
                "arkana.iso",
                "arkanaOS-update-client-base-sequence.txt",
            )
        ]
        result = self.select(releases)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertIn("no system-update-capable", result.stderr)

    def test_first_weekly_release_bootstraps_from_latest_arkup_capable_iso(self) -> None:
        releases = [
            self.release("nightly-220", "2026-10-18T03:00:00Z", "arkana.iso", "arkanaOS-update-client-system-update.txt"),
            self.release("nightly-233", "2026-10-25T03:00:00Z", "arkana.iso", "arkanaOS-update-client-system-update.txt"),
            self.release("nightly-234", "2026-10-26T03:00:00Z", "arkana.iso"),
        ]
        result = self.select(releases, channel="weekly")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.selected_tags(result), ["nightly-233"])

    def test_build_excludes_current_tag_and_uses_previous_scheduled_update(self) -> None:
        releases = [
            self.release("nightly-231", "2026-10-19T03:00:00Z", "arkana.iso", "update.aup", "arkanaOS-update-client-system-update.txt"),
            self.release("nightly-232", "2026-10-26T03:00:00Z", "arkana.iso", "update.aup", "arkanaOS-update-client-system-update.txt"),
        ]
        result = self.select(releases, "--exclude-tag", "nightly-232")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.selected_tags(result), ["nightly-231"])

    def test_requires_aup_and_iso_assets_for_weekly_base(self) -> None:
        releases = [
            self.release("nightly-233", "2026-10-25T03:00:00Z", "update.aup"),
            self.release("nightly-234", "2026-10-26T03:00:00Z", "arkana.iso"),
        ]
        result = self.select(releases)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("no system-update-capable update release or ISO", result.stderr)

    def test_unsupported_tags_are_not_used_as_api_paths(self) -> None:
        releases = [
            self.release(
                "../../attacker",
                "2026-10-27T03:00:00Z",
                "arkana.iso",
                "arkanaOS-update-client-system-update.txt",
            )
        ]
        result = self.select(releases)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")

    def test_no_base_fails_clearly(self) -> None:
        result = self.select([])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("no system-update-capable update release or ISO", result.stderr)

    def test_empty_bootstrap_is_allowed_only_when_explicitly_requested(self) -> None:
        legacy_release = self.release(
            "nightly-877",
            "2026-10-16T11:16:36Z",
            "arkana.iso",
        )
        default_result = self.select([legacy_release])
        self.assertNotEqual(default_result.returncode, 0)
        self.assertEqual(default_result.stdout, "")

        bootstrap_result = self.select(
            [legacy_release], "--allow-empty-bootstrap", channel="nightly"
        )
        self.assertEqual(bootstrap_result.returncode, 0, bootstrap_result.stderr)
        self.assertEqual(self.selected_tags(bootstrap_result), [])


class ScheduledReleaseWorkflowTests(unittest.TestCase):
    def test_pipeline_schedules_nightly_and_weekly_releases_once_per_day(self) -> None:
        """Run the nightly pipeline Sunday and Tuesday-Saturday, weekly Monday."""
        workflow = RUN_ALL_WORKFLOW.read_text(encoding="utf-8")
        schedule = workflow.split("  schedule:\n", 1)[1].split(
            "\n\nconcurrency:", 1
        )[0]
        cron_entries = [
            line.strip()
            for line in schedule.splitlines()
            if line.lstrip().startswith("- cron:")
        ]
        self.assertEqual(
            cron_entries,
            ['- cron: "0 3 * * 0,2-6"', '- cron: "0 3 * * 1"'],
        )
        self.assertIn(
            "release_prefix: ${{ inputs.release_prefix || (github.event_name == 'schedule' && github.event.schedule == '0 3 * * 1' && 'weekly' || 'nightly') }}",
            workflow,
        )
    def test_all_scheduled_runs_build_and_publish_updates(self) -> None:
        """Publish both ISO and signed update packages on nightlies and Mondays."""
        scheduled_condition = "if: github.event_name == 'schedule'"
        run_all = RUN_ALL_WORKFLOW.read_text(encoding="utf-8")
        iso = ISO_WORKFLOW.read_text(encoding="utf-8")
        self.assertEqual(run_all.count(scheduled_condition), 3)
        self.assertEqual(iso.count(scheduled_condition), 2)
        self.assertIn(
            "SCHEDULED_UPDATE_RELEASE: ${{ github.event_name == 'schedule' }}",
            iso,
        )
        self.assertIn('if [[ "$SCHEDULED_UPDATE_RELEASE" == true ]]; then', iso)
        self.assertIn("python3 scripts/select-weekly-update-base.py", run_all)
        self.assertIn("update_bases_json", run_all + iso)
        self.assertIn("releases/assets/$UPDATE_BASE_ISO_ASSET_ID", iso)
        self.assertNotIn("actions/download-artifact@v8", iso)
        self.assertIn("target_commitish: ${{ steps.source.outputs.sha }}", iso)
        self.assertIn("uses: softprops/action-gh-release@v3", iso)
        self.assertNotIn("uses: softprops/action-gh-release@v2", iso)
        self.assertIn("body_path: RELEASE_TEMPLATE.md", iso)
        self.assertIn("generate_release_notes: true", iso)
        self.assertNotIn("sort_by(.published_at) | last", run_all + iso)

    def test_manual_pipeline_rejects_weekly_before_building(self) -> None:
        workflow = RUN_ALL_WORKFLOW.read_text(encoding="utf-8")
        step = workflow.split(
            "      - name: Reject manual weekly release labels\n", 1
        )[1].split("\n      - name:", 1)[0]
        script = textwrap.dedent(step.split("        run: |\n", 1)[1])

        for prefix, expected_returncode in (("weekly", 1), ("nightly", 0)):
            with self.subTest(prefix=prefix):
                environment = os.environ.copy()
                environment["RELEASE_PREFIX"] = prefix
                result = subprocess.run(
                    [
                        "bash",
                        "--noprofile",
                        "--norc",
                        "-e",
                        "-o",
                        "pipefail",
                        "-c",
                        script,
                    ],
                    env=environment,
                    capture_output=True,
                    text=True,
                    timeout=10,
                    check=False,
                )
                self.assertEqual(result.returncode, expected_returncode, result.stderr)
                if prefix == "weekly":
                    self.assertIn("cannot be manually labeled weekly", result.stderr)

    def test_release_notes_document_nightly_and_weekly_assets(self) -> None:
        """Keep scheduled assets clear while reusing the existing release template."""
        template = RELEASE_TEMPLATE.read_text(encoding="utf-8")
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("@@RELEASE_UPDATE_ASSETS@@", template)
        self.assertIn("@@RELEASE_UPDATE_GUIDANCE@@", template)
        self.assertIn("initial scheduled ISO bootstrap", workflow)
        self.assertIn("signed arkup .aup update package", workflow)
        self.assertIn("from-build-N", workflow)
        self.assertIn("Sunday", workflow)
        self.assertIn("# GitHub Generated release notes", template)

    def test_seed_and_signing_keypair_changes_trigger_their_tests(self) -> None:
        workflow = (REPOSITORY / ".github/workflows/update-builder-tests.yml").read_text(
            encoding="utf-8"
        )
        for path in (
            "scripts/seed-build-number.py",
            "scripts/verify-update-signing-keypair.py",
            "tests/test_update_signing_keypair.py",
        ):
            with self.subTest(path=path):
                self.assertEqual(workflow.count(f'      - "{path}"'), 2)
        self.assertIn(
            "python3 -m unittest discover -s tests -p 'test_update_signing_keypair.py' -v",
            workflow,
        )


if __name__ == "__main__":
    unittest.main()
