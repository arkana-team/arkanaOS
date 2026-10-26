"""Check release-workflow concurrency protects scheduled builds."""

from __future__ import annotations

import unittest
from pathlib import Path

REPOSITORY = Path(__file__).resolve().parents[1]
RUN_ALL_WORKFLOW = REPOSITORY / ".github/workflows/00_run_all.yml"


class WeeklyPipelineConcurrencyTests(unittest.TestCase):
    def test_scheduled_builds_queue_without_cancelling_active_releases(self) -> None:
        workflow = RUN_ALL_WORKFLOW.read_text(encoding="utf-8")
        concurrency = workflow.split("\nconcurrency:\n", 1)[1].split("\njobs:\n", 1)[0]

        self.assertRegex(concurrency, r"(?m)^  cancel-in-progress: false$")
        self.assertRegex(concurrency, r"(?m)^  queue: max$")


if __name__ == "__main__":
    unittest.main()
