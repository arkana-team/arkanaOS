"""Guard weekly updates against ISO releases without the arkup client."""

from __future__ import annotations

import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
RUN_ALL = REPOSITORY / ".github/workflows/00_run_all.yml"
ISO_WORKFLOW = REPOSITORY / ".github/workflows/04_stage4_iso.yml"
MARKER = "arkanaOS-update-client-system-update.txt"


class WeeklyUpdateBaseTests(unittest.TestCase):
    def test_scheduled_preflight_selects_a_weekly_or_bootstrap_iso_before_stage_one(self) -> None:
        workflow = RUN_ALL.read_text(encoding="utf-8")
        preflight = workflow.split("  stage1:", 1)[0]

        self.assertIn("if: github.event_name == 'schedule'", preflight)
        self.assertIn(
            "Require a published system-update-compatible ISO as the update base",
            preflight,
        )
        self.assertIn(MARKER, preflight)
        self.assertIn("Publish a compatible ISO before scheduled .aup releases", preflight)
        self.assertIn("needs: validate-weekly-signing-keys", workflow)

    def test_signing_preflight_validates_key_material_before_stage_one(self) -> None:
        workflow = RUN_ALL.read_text(encoding="utf-8")
        preflight = workflow.split("  stage1:", 1)[0]

        self.assertIn('base64 --decode "$key_file"', preflight)
        self.assertIn('"$(wc -c < "$raw_key")" -ne 32', preflight)
        self.assertIn("must each decode to 32 bytes", preflight)

    def test_iso_release_marker_is_created_only_when_arkup_is_installed(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        marker_step = workflow.split("      - name: Mark ISO as arkup system-update-capable", 1)[1]
        marker_step = marker_step.split("      - name:", 1)[0]
        update_step = workflow.split(
            "      - name: Build signed update package for weekly developer release", 1
        )[1]
        release_assets = workflow.split("      - name: Select release assets", 1)[1]

        self.assertIn("! -x output/iso-root/usr/bin/arkup", marker_step)
        self.assertIn("arkup-client=/usr/bin/arkup", marker_step)
        self.assertIn("--base-sequence", marker_step)
        self.assertIn("--system-update", marker_step)
        self.assertIn("system-update=1", marker_step)
        self.assertIn('! -x "$BASE_ROOT/usr/bin/arkup"', update_step)
        update_builder = (REPOSITORY / "scripts/build-update-pack.py").read_text()
        self.assertIn("--base-sequence", update_builder)
        self.assertIn("--system-update", update_builder)
        self.assertIn(f'echo "output/{MARKER}"', release_assets)
        self.assertIn(MARKER, (REPOSITORY / "RELEASE_TEMPLATE.md").read_text())

    def test_update_base_lookup_selects_previous_weekly_from_paginated_history(self) -> None:
        workflow = ISO_WORKFLOW.read_text(encoding="utf-8")
        update_step = workflow.split(
            "      - name: Build signed update package for weekly developer release", 1
        )[1].split("      - name:", 1)[0]

        self.assertIn(
            'gh api --paginate "repos/$GITHUB_REPOSITORY/releases?per_page=100"',
            update_step,
        )
        self.assertIn("jq -s 'add'", update_step)
        self.assertIn(
            'python3 scripts/select-weekly-update-base.py --exclude-tag "$RELEASE_ID"',
            update_step,
        )
        self.assertNotIn("sort_by(.published_at) | last", update_step)


if __name__ == "__main__":
    unittest.main(verbosity=2)
