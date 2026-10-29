"""Guard scheduled updates against incompatible or expiring base sources."""

from __future__ import annotations

import os
import runpy
import subprocess
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

    def test_all_scheduled_releases_upload_update_artifacts(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        upload_step = workflow.split(
            "      - name: Upload Signed arkanaOS Update Artifact", 1
        )[1].split("      - name:", 1)[0]
        release_assets = workflow.split(
            "      - name: Select release assets", 1
        )[1].split("      - name:", 1)[0]
        scheduled_release = "github.event_name == 'schedule'"
        self.assertIn(f"if: {scheduled_release}", upload_step)
        self.assertIn(
            f"SCHEDULED_UPDATE_RELEASE: ${{{{ {scheduled_release} }}}}",
            release_assets,
        )
        self.assertIn('if [[ "$SCHEDULED_UPDATE_RELEASE" == true ]]', release_assets)


if __name__ == "__main__":
    unittest.main(verbosity=2)
