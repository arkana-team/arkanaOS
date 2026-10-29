"""Guard scheduled updates against incompatible or expiring base sources."""

from __future__ import annotations

import base64
import os
import runpy
import subprocess
import tempfile
import textwrap
import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
RUN_ALL = REPOSITORY / ".github/workflows/00_run_all.yml"
ISO_WORKFLOW = REPOSITORY / ".github/workflows/04_stage4_iso.yml"
MARKER = "arkanaOS-update-client-system-update.txt"
BASE_PROVENANCE = runpy.run_path(
    str(REPOSITORY / "scripts/verify-weekly-base-provenance.py")
)


class WeeklyUpdateBaseTests(unittest.TestCase):
    def test_release_tag_resolves_to_expected_build_number(self) -> None:
        self.assertEqual(BASE_PROVENANCE["release_build_number"]("weekly-233"), "233")

    def test_scheduled_preflight_selects_persistent_release_isos_before_stage_one(self) -> None:
        workflow = RUN_ALL.read_text(encoding="utf-8")
        preflight = workflow.split("  stage1:", 1)[0]

        self.assertIn("if: github.event_name == 'schedule'", preflight)
        self.assertIn("Verify persistent release ISOs as update bases", preflight)
        self.assertIn(MARKER, preflight)
        self.assertIn("scripts/verify-weekly-base-provenance.py", preflight)
        self.assertIn(
            "UPDATE_BASE_CHANNEL: ${{ github.event.schedule == '0 3 * * 1' && 'weekly' || 'nightly' }}",
            preflight,
        )
        self.assertIn(
            'python3 scripts/select-weekly-update-base.py --channel "$UPDATE_BASE_CHANNEL"',
            preflight,
        )
        self.assertIn("--allow-empty-bootstrap", preflight)
        self.assertIn("will publish a signed ISO base", preflight)
        self.assertIn('update_bases_json=%s\\n', preflight)
        self.assertNotIn("actions/runs/$SOURCE_RUN_ID/artifacts", preflight)
        self.assertIn("needs: validate-scheduled-update-prerequisites", workflow)

    def test_signing_preflight_validates_key_material_before_stage_one(self) -> None:
        workflow = RUN_ALL.read_text(encoding="utf-8")
        preflight = workflow.split("  stage1:", 1)[0]

        self.assertIn('base64 --decode "$key_file"', preflight)
        self.assertIn('"$(wc -c < "$raw_key")" -ne 32', preflight)
        self.assertIn("must each decode to 32 bytes", preflight)
        checker = "scripts/verify-update-signing-keypair.py"
        self.assertIn(checker, preflight)
        self.assertLess(preflight.index("actions/checkout@v4"), preflight.index(checker))

    def test_iso_is_marked_only_when_the_pinned_arkup_client_is_installed(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        marker_step = workflow.split(
            "      - name: Mark ISO as arkup system-update-capable", 1
        )[1].split("      - name:", 1)[0]
        update_step = workflow.split(
            "      - name: Build signed update packages for scheduled developer release", 1
        )[1].split("      - name:", 1)[0]
        release_assets = workflow.split(
            "      - name: Select release assets", 1
        )[1].split("      - name:", 1)[0]

        self.assertIn("! -x output/iso-root/usr/bin/arkup", marker_step)
        self.assertIn("arkup-client=/usr/bin/arkup", marker_step)
        self.assertIn("--base-sequence", marker_step)
        self.assertIn("--system-update", marker_step)
        self.assertIn("--userspec=", marker_step)
        self.assertIn("system-update=1", marker_step)
        self.assertIn('"$SOURCE_RUN_ID" == "$GITHUB_RUN_ID"', marker_step)
        self.assertIn('inputs.update_bases_json', workflow)
        self.assertIn('type == "array" and length <= 2', update_step)
        self.assertIn('mkdir -p output/updates', update_step)
        self.assertIn('echo "update_count=$BASE_COUNT"', update_step)
        self.assertIn("releases/assets/$UPDATE_BASE_ISO_ASSET_ID", update_step)
        self.assertIn("releases/assets/$UPDATE_BASE_MARKER_ID", update_step)
        self.assertIn("sha256sum --check --status", update_step)
        self.assertIn("unsquashfs -no-progress -processors 1", update_step)
        self.assertNotIn("chroot", update_step.lower())
        self.assertEqual(update_step.count('"$BASE_ROOT/usr/bin/arkup"'), 3)
        self.assertIn('! -x "$BASE_ROOT/usr/bin/arkup"', update_step)
        self.assertNotIn("sudo unsquashfs", update_step)
        self.assertIn("from-build-${UPDATE_BASE_BUILD_NUMBER}.aup", update_step)
        self.assertIn("from-build-{base_release.build}", (REPOSITORY / "scripts/build-update-pack.py").read_text())
        self.assertIn(f'echo "output/{MARKER}"', release_assets)

    def test_monday_builds_both_weekly_and_latest_release_paths(self) -> None:
        selector = (REPOSITORY / "scripts/select-weekly-update-base.py").read_text()
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        self.assertIn("previous_weekly", selector)
        self.assertIn("latest_update", selector)
        self.assertIn("for ((base_index = 0; base_index < BASE_COUNT; base_index++))", workflow)
        self.assertIn("from-build-${UPDATE_BASE_BUILD_NUMBER}.aup", workflow)

    def test_update_base_tag_validation_accepts_supported_build_tags(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        validation_line = next(
            line for line in workflow.splitlines()
            if '"$UPDATE_BASE_RELEASE_TAG" =~' in line
        )
        pattern = validation_line.split(" =~ ", 1)[1].split(" && \\", 1)[0]
        self.assertTrue(pattern.startswith("^") and pattern.endswith("$"))
        accepted_tags = (
            "nightly-231", "weekly-232", "v1.0-alpha1-build-233",
            "v1.0-beta2-build-234", "v1.0-build-235",
        )
        rejected_tags = ("v1.0-alpha1-233", "v1.0-beta2-234", "Nightly-231")
        for tag in accepted_tags:
            with self.subTest(tag=tag):
                result = subprocess.run(
                    ["bash", "--noprofile", "--norc", "-c", '[[ "$TAG" =~ $PATTERN ]]'],
                    env={**os.environ, "TAG": tag, "PATTERN": pattern},
                    check=False,
                )
                self.assertEqual(result.returncode, 0, tag)
        for tag in rejected_tags:
            with self.subTest(tag=tag):
                result = subprocess.run(
                    ["bash", "--noprofile", "--norc", "-c", '[[ "$TAG" =~ $PATTERN ]]'],
                    env={**os.environ, "TAG": tag, "PATTERN": pattern},
                    check=False,
                )
                self.assertNotEqual(result.returncode, 0, tag)

    def test_scheduled_bootstrap_skips_empty_update_artifact_then_publishes_updates(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        upload_step = workflow.split(
            "      - name: Upload Signed arkanaOS Update Artifact", 1
        )[1].split("      - name:", 1)[0]
        release_assets = workflow.split(
            "      - name: Select release assets", 1
        )[1].split("      - name:", 1)[0]
        self.assertIn(
            "if: github.event_name == 'schedule' && steps.build-updates.outputs.update_count != '0'",
            upload_step,
        )
        self.assertIn(
            "SCHEDULED_UPDATE_RELEASE: ${{ github.event_name == 'schedule' }}",
            release_assets,
        )
        self.assertIn('if [[ "$SCHEDULED_UPDATE_RELEASE" == true ]]', release_assets)
        self.assertIn('if [[ "$UPDATE_COUNT" -gt 0 ]]; then', release_assets)
        self.assertIn("output/updates/arkanaOS-update-signing.pub", release_assets)
        self.assertIn(
            "@@RELEASE_UPDATE_ASSETS@@",
            (REPOSITORY / "RELEASE_TEMPLATE.md").read_text(encoding="utf-8"),
        )
        self.assertIn("initial scheduled ISO bootstrap", workflow)

    def test_bootstrap_update_step_publishes_key_without_downloading_a_base(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        step = workflow.split(
            "      - name: Build signed update packages for scheduled developer release\n",
            1,
        )[1].split("      - name:", 1)[0]
        script = textwrap.dedent(step.split("        run: |\n", 1)[1])

        with tempfile.TemporaryDirectory(prefix="arkana-update-bootstrap-") as temporary:
            root = Path(temporary)
            binary_dir = root / "bin"
            runner_temp = root / "runner-temp"
            binary_dir.mkdir()
            runner_temp.mkdir()
            (binary_dir / "sudo").write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
            (binary_dir / "gh").write_text(
                "#!/bin/sh\nprintf '12345\\n'\n", encoding="utf-8"
            )
            for command in (binary_dir / "sudo", binary_dir / "gh"):
                command.chmod(0o755)
            signing_key = bytes(range(32))
            public_key = bytes(reversed(range(32)))
            github_output = root / "github-output"
            environment = os.environ.copy()
            environment.update(
                {
                    "PATH": f"{binary_dir}:{environment['PATH']}",
                    "RUNNER_TEMP": str(runner_temp),
                    "GITHUB_OUTPUT": str(github_output),
                    "GITHUB_REPOSITORY": "arkana-team/arkanaOS",
                    "GH_TOKEN": "test-token",
                    "ARKUP_UPDATE_SIGNING_KEY_B64": base64.b64encode(signing_key).decode(),
                    "ARKUP_UPDATE_PUBLIC_KEY_B64": base64.b64encode(public_key).decode(),
                    "UPDATE_BASES_JSON": "[]",
                }
            )
            result = subprocess.run(
                ["bash", "--noprofile", "--norc", "-e", "-o", "pipefail", "-c", script],
                cwd=root,
                env=environment,
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                (root / "output/updates/arkanaOS-update-signing.pub").read_bytes(),
                public_key,
            )
            self.assertIn("update_count=0\n", github_output.read_text())
            self.assertEqual(list((root / "output/updates").glob("*.aup")), [])
            self.assertFalse((runner_temp / "arkana-update-key").exists())

    def test_release_asset_selection_handles_bootstrap_and_update_releases(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        step = workflow.split("      - name: Select release assets\n", 1)[1].split(
            "      - name:", 1
        )[0]
        script = textwrap.dedent(step.split("        run: |\n", 1)[1])

        for update_count in (0, 1):
            with self.subTest(update_count=update_count), tempfile.TemporaryDirectory(
                prefix="arkana-release-assets-"
            ) as temporary:
                root = Path(temporary)
                updates = root / "output/updates"
                updates.mkdir(parents=True)
                for name in (
                    "arkana.iso",
                    "arkanaOS-update-client.txt",
                    MARKER,
                ):
                    (root / "output" / name).touch()
                (updates / "arkanaOS-update-signing.pub").touch()
                if update_count:
                    (updates / "arkanaos-nightly-234-from-build-233.aup").touch()
                    (updates / "arkanaos-nightly-234-from-build-233.aup.sha256").touch()
                github_output = root / "github-output"
                environment = os.environ.copy()
                environment.update(
                    {
                        "GITHUB_OUTPUT": str(github_output),
                        "SCHEDULED_UPDATE_RELEASE": "true",
                        "UPDATE_COUNT": str(update_count),
                    }
                )
                result = subprocess.run(
                    ["bash", "--noprofile", "--norc", "-e", "-o", "pipefail", "-c", script],
                    cwd=root,
                    env=environment,
                    capture_output=True,
                    text=True,
                    timeout=10,
                    check=False,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                lines = github_output.read_text().splitlines()
                selected = set(lines[lines.index("files<<EOF") + 1 : lines.index("EOF")])
                self.assertIn("output/arkana.iso", selected)
                self.assertIn(f"output/{MARKER}", selected)
                self.assertIn("output/updates/arkanaOS-update-signing.pub", selected)
                package_assets = {name for name in selected if name.endswith((".aup", ".aup.sha256"))}
                self.assertEqual(len(package_assets), 2 * update_count)


if __name__ == "__main__":
    unittest.main(verbosity=2)
