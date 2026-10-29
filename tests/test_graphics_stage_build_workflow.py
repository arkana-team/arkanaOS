"""Keep the Cairo/libpng graphics build check provenance-bound and resource-limited."""

from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class GraphicsStageBuildWorkflowTests(unittest.TestCase):
    def test_workflow_is_limited_to_graphics_pull_request_changes(self) -> None:
        workflow = (ROOT / ".github/workflows/graphics-stage-build.yml").read_text(
            encoding="utf-8"
        )
        self.assertIn("pull_request:", workflow)
        self.assertIn('"arkanas/05_graphics.mk"', workflow)
        self.assertIn('"arkanas/libpng.mk"', workflow)
        self.assertIn('git diff --name-only "$PR_BASE_SHA" "$GITHUB_SHA"', workflow)
        self.assertIn("This graphics-stage check cannot reuse a base artifact", workflow)
        self.assertIn("permissions:\n  actions: read\n  contents: read", workflow)

    def test_stage_two_artifact_must_come_from_a_trusted_compatible_run(self) -> None:
        workflow = (ROOT / ".github/workflows/graphics-stage-build.yml").read_text(
            encoding="utf-8"
        )
        for required in (
            '"$DEFAULT_BRANCH"',
            '"$PR_BASE_SHA"',
            '"$SOURCE_SHA" "$PR_BASE_SHA"',
            '"$GITHUB_REPOSITORY"',
            '"stage1 / 1. Build Base System"',
            '"stage2 / 2. Build Extensions & Toolchain"',
            '"arkana-stage2"',
            'repository: ${{ github.repository }}',
        ):
            self.assertIn(required, workflow)

    def test_graphics_build_uses_two_jobs_and_three_gib(self) -> None:
        workflow = (ROOT / ".github/workflows/graphics-stage-build.yml").read_text(
            encoding="utf-8"
        )
        self.assertIn("--cpus=2 --memory=3g --memory-swap=3g", workflow)
        self.assertIn("THREADS=2", workflow)
        self.assertIn("NINJAJOBS=2", workflow)
        self.assertIn("ccache-stage3", workflow)
        self.assertIn("graphics-stage-build-logs", workflow)


if __name__ == "__main__":
    unittest.main()
