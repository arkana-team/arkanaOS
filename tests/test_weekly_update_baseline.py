"""Guard weekly updates against ISO releases without the arkup client."""

from __future__ import annotations

import runpy
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
    def test_weekly_release_tag_resolves_to_the_expected_retained_iso_artifact(self) -> None:
        self.assertEqual(
            BASE_PROVENANCE["release_artifact_name"]("weekly-233"),
            ("arkanaOS-weekly-233-iso", "233"),
        )

    def test_scheduled_preflight_selects_an_update_or_bootstrap_iso_before_stage_one(self) -> None:
        workflow = RUN_ALL.read_text(encoding="utf-8")
        preflight = workflow.split("  stage1:", 1)[0]

        self.assertIn("if: github.event_name == 'schedule'", preflight)
        self.assertIn(
            "Require a published system-update-compatible ISO as the update base",
            preflight,
        )
        self.assertIn(MARKER, preflight)
        self.assertIn("Publish a compatible ISO from Run All before scheduled .aup releases", preflight)
        self.assertIn("scripts/verify-weekly-base-provenance.py", preflight)
        self.assertIn("actions/runs/$SOURCE_RUN_ID/artifacts", preflight)
        self.assertIn("artifact_id", preflight)
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

    def test_iso_release_marker_is_created_only_when_arkup_is_installed(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        marker_step = workflow.split("      - name: Mark ISO as arkup system-update-capable", 1)[1]
        marker_step = marker_step.split("      - name:", 1)[0]
        update_step = workflow.split(
            "      - name: Build signed update package for scheduled developer release", 1
        )[1]
        release_assets = workflow.split("      - name: Select release assets", 1)[1]

        self.assertIn("! -x output/iso-root/usr/bin/arkup", marker_step)
        self.assertIn("arkup-client=/usr/bin/arkup", marker_step)
        self.assertIn("--base-sequence", marker_step)
        self.assertIn("--system-update", marker_step)
        self.assertIn("--userspec=", marker_step)
        self.assertIn("system-update=1", marker_step)
        self.assertIn("source-run-id=%s", marker_step)
        self.assertIn("source-sha=%s", marker_step)
        self.assertIn('"$SOURCE_RUN_ID" == "$GITHUB_RUN_ID"', marker_step)
        self.assertIn('! -x "$BASE_ROOT/usr/bin/arkup"', update_step)
        self.assertIn("artifact-ids: ${{ inputs.update_base_artifact_id }}", workflow)
        self.assertIn('cmp -s -- "$BASE_MARKER" "$RELEASE_MARKER"', update_step)
        self.assertIn("unsquashfs -no-progress -processors 1", update_step)
        self.assertNotIn("chroot", update_step.lower())
        self.assertEqual(
            update_step.count('"$BASE_ROOT/usr/bin/arkup"'),
            3,
            "the base Arkup path should only appear in file and executable checks",
        )
        self.assertIn('! -x "$BASE_ROOT/usr/bin/arkup"', update_step)
        self.assertNotIn("sudo unsquashfs", update_step)
        self.assertNotIn("gh release download", update_step)
        update_builder = (REPOSITORY / "scripts/build-update-pack.py").read_text()
        self.assertIn("--base-sequence", update_builder)
        self.assertIn("--system-update", update_builder)
        self.assertIn(f'echo "output/{MARKER}"', release_assets)
        self.assertIn(MARKER, (REPOSITORY / "RELEASE_TEMPLATE.md").read_text())

    def test_weekly_base_selection_is_provenanced_before_building(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        download_step = workflow.split(
            "      - name: Download verified update base ISO artifact", 1
        )[1].split("      - name:", 1)[0]
        self.assertIn("artifact-ids: ${{ inputs.update_base_artifact_id }}", download_step)
        self.assertIn("uses: actions/download-artifact@v8", download_step)
        self.assertIn("digest-mismatch: error", download_step)
        self.assertIn("run-id: ${{ inputs.update_base_run_id }}", download_step)
        self.assertIn("repository: ${{ github.repository }}", download_step)
        self.assertNotIn("gh release download", workflow)
        self.assertIn(
            "python3 scripts/select-weekly-update-base.py", RUN_ALL.read_text()
        )
        self.assertIn("weekly-[0-9]+", workflow)

    def test_all_scheduled_releases_upload_signed_update_artifacts(self) -> None:
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
