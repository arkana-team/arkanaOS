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
            ("nightly", "nightly", "nightly", "nightly-233", "true", "nightly"),
            ("weekly", "nightly", "nightly", "nightly-233", "true", "nightly"),
            (
                "r1-a1",
                "1.0 (alpha 1)",
                "1.0-alpha1",
                "v1.0-alpha1-build-233",
                "true",
                "r1-a1",
            ),
            (
                "r1-b1",
                "1.0 (beta 1)",
                "1.0-beta1",
                "v1.0-beta1-build-233",
                "true",
                "r1-b1",
            ),
            ("r1-1", "1.0", "1.0", "v1.0-build-233", "false", "r1-1"),
        )
        for prefix, version, version_id, release_id, prerelease, metadata_prefix in cases:
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
                    (metadata / "arkana-release-prefix").read_text().strip(),
                    metadata_prefix,
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
        workflow_ref: str | None = None,
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
        helper_dir = root / "runner-temp/arkanaOS-release-helpers"
        helper_dir.mkdir(parents=True)
        shutil.copy2(
            REPOSITORY / "scripts/format-scheduled-release-tag.py",
            helper_dir / "format-scheduled-release-tag.py",
        )
        shutil.copy2(RELEASE_TEMPLATE, root / "RELEASE_TEMPLATE.md")
        runner_temp = root / "runner-temp"
        runner_temp.mkdir(exist_ok=True)
        fake_bin = root / "bin"
        fake_bin.mkdir()
        fake_gh = fake_bin / "gh"
        fake_gh.write_text(
            "#!/bin/sh\n"
            'if [ "$1" = api ]; then cat "$FAKE_RUN_JSON"; else exit 2; fi\n',
            encoding="utf-8",
        )
        fake_gh.chmod(0o755)
        source_run_json = root / "source-run.json"
        source_run_json.write_text(
            json.dumps(
                {
                    "id": 12345,
                    "run_number": 29,
                    "run_attempt": 1,
                    "name": "Run All Pipeline Stages",
                    "event": event_name,
                    "actor": {"login": "debarkak"},
                    "triggering_actor": {"login": "debarkak"},
                    "repository": {"full_name": "arkana-team/arkanaOS"},
                    "head_branch": "main",
                    "head_sha": "a" * 40,
                    "run_started_at": "2026-11-16T11:07:03Z",
                    "html_url": "https://github.com/arkana-team/arkanaOS/actions/runs/12345",
                }
            ),
            encoding="utf-8",
        )
        github_env = root / "github-env"
        environment = os.environ.copy()
        environment["GITHUB_ENV"] = str(github_env)
        environment["GITHUB_EVENT_NAME"] = event_name
        environment["GITHUB_REPOSITORY"] = "arkana-team/arkanaOS"
        environment["GITHUB_REF"] = "refs/heads/main"
        environment["GITHUB_WORKFLOW_REF"] = workflow_ref or (
            "arkana-team/arkanaOS/.github/workflows/00_run_all.yml@refs/heads/main"
        )
        environment["SOURCE_RUN_ID"] = "12345"
        environment["FAKE_RUN_JSON"] = str(source_run_json)
        environment["RUNNER_TEMP"] = str(runner_temp)
        environment["GH_TOKEN"] = "test-token"
        environment["PATH"] = f"{fake_bin}:{environment['PATH']}"
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
                "Developer build for testing and development only.",
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
                event_name = "schedule" if prefix == "nightly" else "workflow_dispatch"
                result = self.run_release_step(
                    root,
                    prefix=prefix,
                    release_id=release_id,
                    version=f"{version}\n",
                    prerelease=prerelease,
                    event_name=event_name,
                    update_bases_json=None,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                expected_name = (
                    f"{prefix}-20261116-build-233"
                    if prefix == "nightly"
                    else f"arkanaOS {version} build 233"
                )
                if prefix == "nightly":
                    update_assets = (
                        "This is the initial update-capable ISO bootstrap. It includes the verification public key "
                        "and seeds the signed .aup update path; update packages begin with the next update-enabled release."
                    )
                    update_guidance = (
                        "No .aup package is attached because there is no earlier update-capable release to target. "
                        "After the next release includes its update package, trust the verification key "
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
                if prefix == "nightly":
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
            self.assertIn("latest update-capable release", rendered)
            self.assertIn("sudo arkup trust ./arkanaOS-update-signing.pub", rendered)
            self.assertIn("sudo arkup apply ./path/to/update.aup", rendered)
            self.assertNotIn("@@RELEASE_", rendered)

    def test_weekly_release_label_requires_full_pipeline_workflow(self) -> None:
        with tempfile.TemporaryDirectory(prefix="arkana-iso-release-") as temporary:
            root = Path(temporary)
            result = self.run_release_step(
                root,
                prefix="weekly",
                release_id="weekly-233",
                version="weekly",
                prerelease="true",
                workflow_ref=(
                    "arkana-team/arkanaOS/.github/workflows/"
                    "04_stage4_iso.yml@refs/heads/main"
                ),
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertIn("manual input alias", result.stderr)

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

    def test_weekly_release_keeps_previous_weekly_and_latest_nightly_paths(self) -> None:
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

    def test_weekly_keeps_iso_only_weekly_bootstrap_and_latest_update_release(self) -> None:
        releases = [
            self.release(
                "weekly-935",
                "2026-11-16T15:36:55Z",
                "arkana.iso",
                "arkanaOS-update-client-system-update.txt",
            ),
            self.release(
                "nightly-20261117-build-936",
                "2026-11-17T10:00:00Z",
                "arkana.iso",
                "arkanaos-nightly.aup",
                "arkanaOS-update-client-system-update.txt",
            ),
        ]
        result = self.select(releases, channel="weekly")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            self.selected_tags(result),
            ["weekly-935", "nightly-20261117-build-936"],
        )

    def test_nightly_uses_newer_weekly_as_base_after_manual_weekly_release(self) -> None:
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


class ArkUpCapabilityWorkflowTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        """Load the ISO workflow's ArkUp capability check for direct testing."""
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        step = workflow.split(
            "      - name: Mark ISO as arkup system-update-capable\n", 1
        )[1].split("\n      - name:", 1)[0]
        cls.script = textwrap.dedent(step.split("        run: |\n", 1)[1])

    def test_capability_check_uses_chroot_group_syntax(self) -> None:
        """Pass id's whitespace-separated groups as chroot's comma list."""
        with tempfile.TemporaryDirectory(prefix="arkana-arkup-capability-") as temporary:
            root = Path(temporary)
            iso_arkup = root / "output/iso-root/usr/bin/arkup"
            iso_arkup.parent.mkdir(parents=True)
            iso_arkup.touch()
            iso_arkup.chmod(0o755)
            runner_temp = root / "runner-temp"
            runner_temp.mkdir()
            mock_bin = root / "bin"
            mock_bin.mkdir()
            (mock_bin / "id").write_text(
                "#!/bin/sh\n"
                "case \"$1\" in\n"
                "  -G) printf '1001 998\\n' ;;\n"
                "  -u|-g) printf '1001\\n' ;;\n"
                "  *) exit 2 ;;\n"
                "esac\n",
                encoding="utf-8",
            )
            (mock_bin / "sudo").write_text(
                "#!/bin/sh\nexec \"$@\"\n", encoding="utf-8"
            )
            chroot_args = root / "chroot-args"
            (mock_bin / "chroot").write_text(
                "#!/bin/sh\n"
                "printf '%s\\n' \"$@\" > \"$CHROOT_ARGS_FILE\"\n"
                "if [ \"$1\" != '--groups=1001,998' ]; then\n"
                "  printf 'invalid group list: %s\\n' \"$1\" >&2\n"
                "  exit 125\n"
                "fi\n"
                "printf '%s\\n' \"$ARKUP_HELP_OUTPUT\"\n",
                encoding="utf-8",
            )
            for command in mock_bin.iterdir():
                command.chmod(0o755)

            github_output = root / "github-output"
            environment = os.environ.copy()
            environment.update(
                {
                    "PATH": f"{mock_bin}{os.pathsep}{environment['PATH']}",
                    "CHROOT_ARGS_FILE": str(chroot_args),
                    "DEFAULT_BRANCH": "main",
                    "SOURCE_RUN_ID": "222",
                    "SOURCE_SHA": "a" * 40,
                    "GITHUB_RUN_ID": "111",
                    "GITHUB_SHA": "b" * 40,
                    "GITHUB_REF": "refs/heads/main",
                    "GITHUB_WORKFLOW_REF": (
                        "arkana-team/arkanaOS/.github/workflows/00_run_all.yml@"
                        "refs/heads/main"
                    ),
                    "GITHUB_REPOSITORY": "arkana-team/arkanaOS",
                    "GITHUB_OUTPUT": str(github_output),
                    "RUNNER_TEMP": str(runner_temp),
                }
            )
            marker = root / "output/arkanaOS-update-client.txt"
            cases = (
                (
                    "--base-sequence <BASE_SEQUENCE>\n--system-update",
                    0,
                    True,
                    None,
                ),
                ("--system-update", 1, False, "--base-sequence"),
                ("--base-sequence <BASE_SEQUENCE>", 1, False, "--system-update"),
            )
            for help_output, expected_status, expected_marker, missing_option in cases:
                with self.subTest(missing_option=missing_option):
                    github_output.unlink(missing_ok=True)
                    chroot_args.unlink(missing_ok=True)
                    marker.unlink(missing_ok=True)
                    environment["ARKUP_HELP_OUTPUT"] = help_output
                    result = subprocess.run(
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

                    self.assertEqual(result.returncode, expected_status, result.stderr)
                    self.assertEqual(marker.is_file(), expected_marker)
                    self.assertEqual(
                        chroot_args.read_text(encoding="utf-8").splitlines(),
                        [
                            "--groups=1001,998",
                            "--userspec=1001:1001",
                            "output/iso-root",
                            "/usr/bin/arkup",
                            "pack",
                            "--help",
                        ],
                    )
                    if missing_option:
                        self.assertIn(
                            f"missing required option: {missing_option}", result.stderr
                        )
                    else:
                        self.assertIn(
                            "system_update_capable=false\n",
                            github_output.read_text(encoding="utf-8"),
                        )


class ScheduledReleaseWorkflowTests(unittest.TestCase):
    def test_pipeline_schedules_nightly_and_keeps_weekly_manual(self) -> None:
        workflow = RUN_ALL_WORKFLOW.read_text(encoding="utf-8")
        schedule = workflow.split("  schedule:\n", 1)[1].split(
            "\n\nconcurrency:", 1
        )[0]
        cron_entries = [
            line.strip()
            for line in schedule.splitlines()
            if line.lstrip().startswith("- cron:")
        ]
        self.assertEqual(cron_entries, ['- cron: "17 3 * * 0,2-6"'])
        self.assertIn("default: weekly", workflow)
        self.assertIn("Use weekly for a manual developer run", workflow)
        self.assertNotIn("Monday is the weekly developer release", workflow)
    def test_scheduled_nightly_and_manual_weekly_build_update_packages(self) -> None:
        run_all = RUN_ALL_WORKFLOW.read_text(encoding="utf-8")
        iso = ISO_WORKFLOW.read_text(encoding="utf-8")
        self.assertEqual(run_all.count("if: github.event_name == 'schedule'"), 3)
        self.assertIn("inputs.update_bases_json != ''", iso)
        self.assertIn("UPDATE_RELEASE_BUILD", iso)
        self.assertIn("if [[ \"$UPDATE_RELEASE_BUILD\" == true ]]; then", iso)
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
    def test_manual_pipeline_accepts_weekly_as_an_explicit_release_prefix(self) -> None:
        workflow = RUN_ALL_WORKFLOW.read_text(encoding="utf-8")
        input_block = workflow.split("      release_prefix:", 1)[1].split("  schedule:", 1)[0]
        self.assertIn("weekly", input_block)
        self.assertIn("default: weekly", input_block)
        self.assertIn("all developer builds publish with nightly tags", input_block)
        self.assertNotIn("Reject manual weekly release labels", workflow)
    def test_release_notes_document_build_assets_and_actions_metadata(self) -> None:
        template = RELEASE_TEMPLATE.read_text(encoding="utf-8")
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("@@RELEASE_UPDATE_ASSETS@@", template)
        self.assertIn("@@RELEASE_UPDATE_GUIDANCE@@", template)
        self.assertIn("initial update-capable ISO bootstrap", workflow)
        self.assertIn("signed arkup .aup update package", workflow)
        self.assertIn("from-build-N", workflow)
        self.assertIn("latest update-capable release", workflow)
        self.assertIn("append-actions-build-details.py", workflow)
        self.assertNotIn("Supported for 7 days.", workflow)
        self.assertIn("WORKFLOW_SHA: ${{ github.sha }}", workflow)
        self.assertIn("contents/scripts/$helper?ref=$WORKFLOW_SHA", workflow)
        self.assertIn(
            'python3 "$RUNNER_TEMP/arkanaOS-release-helpers/format-scheduled-release-tag.py"',
            workflow,
        )
        self.assertIn(
            'python3 "$RUNNER_TEMP/arkanaOS-release-helpers/append-actions-build-details.py"',
            workflow,
        )
        self.assertIn("for attempt in 1 2 3; do", workflow)
        details_step = workflow.split(
            "      - name: Add Actions build details to release notes", 1
        )[1].split("      - name:", 1)[0]
        self.assertLess(
            workflow.index("      - name: Add Actions build details to release notes"),
            workflow.index("      - name: Publish GitHub Release"),
        )
        self.assertNotIn("gh release edit", details_step)
        self.assertIn("--captured-at", details_step)
        self.assertIn('mv "$UPDATED_NOTES" RELEASE_TEMPLATE.md', details_step)
        self.assertIn("Actions build details could not be prepared", details_step)
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
