"""Check dated release tags and auditable Actions metadata in release notes."""

from __future__ import annotations

import runpy
import unittest
from datetime import UTC, datetime
from pathlib import Path

REPOSITORY = "arkana-team/arkanaOS"
REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
TAG_FORMATTER = runpy.run_path(str(REPOSITORY_ROOT / "scripts/format-scheduled-release-tag.py"))
DETAILS = runpy.run_path(str(REPOSITORY_ROOT / "scripts/append-actions-build-details.py"))


class ScheduledReleaseTagTests(unittest.TestCase):
    def test_tag_uses_the_source_run_date_and_build_number(self) -> None:
        run = {"run_started_at": "2026-11-16T11:07:14Z"}
        self.assertEqual(
            TAG_FORMATTER["release_tag"]("weekly", "935", run),
            "weekly-20261116-build-935",
        )

    def test_tag_date_uses_utc_when_source_timestamp_has_an_offset(self) -> None:
        run = {"run_started_at": "2026-11-16T23:30:00-02:00"}
        self.assertEqual(
            TAG_FORMATTER["release_tag"]("nightly", "936", run),
            "nightly-20261117-build-936",
        )

    def test_rejects_unknown_channel_or_malformed_run_timestamp(self) -> None:
        with self.assertRaises(ValueError):
            TAG_FORMATTER["release_tag"]("stable", "935", {"created_at": "2026-11-16"})
        with self.assertRaises(ValueError):
            TAG_FORMATTER["release_tag"]("weekly", "0", {"created_at": "2026-11-16T00:00:00Z"})
        with self.assertRaises(ValueError):
            TAG_FORMATTER["release_tag"]("weekly", "935", {"created_at": "2026-11-16"})


class ActionsBuildDetailsTests(unittest.TestCase):
    def setUp(self) -> None:
        self.started = datetime(2026, 11, 16, 10, 0, tzinfo=UTC)
        self.run = {
            "id": 12345,
            "run_number": 935,
            "run_attempt": 1,
            "name": "Run All Pipeline Stages",
            "event": "workflow_dispatch",
            "triggering_actor": {"login": "debarkak"},
            "actor": {"login": "github-actions[bot]"},
            "head_branch": "main",
            "head_sha": "a" * 40,
            "run_started_at": self.started.isoformat(),
            "repository": {"full_name": REPOSITORY},
            "html_url": f"https://github.com/{REPOSITORY}/actions/runs/12345",
        }

    def test_includes_actor_run_link_commit_and_elapsed_duration(self) -> None:
        details = DETAILS["build_details"](
            self.run, "2026-11-16T12:31:09Z", REPOSITORY
        )
        self.assertIn("[Run All Pipeline Stages](https://github.com/", details)
        self.assertIn("Triggered by: `@debarkak`", details)
        self.assertIn("Trigger: `workflow_dispatch`", details)
        self.assertIn(f"[`{self.run['head_sha'][:12]}`]", details)
        self.assertIn("Build duration through release publication: `2h 31m 9s`", details)

    def test_replaces_existing_metadata_without_duplicating_it(self) -> None:
        details = DETAILS["build_details"](
            self.run, "2026-11-16T12:31:09Z", REPOSITORY
        )
        original = "# Weekly Release\n\n## Changes\n\n"
        updated = DETAILS["with_build_details"](original, details)
        updated_again = DETAILS["with_build_details"](updated, details)
        self.assertEqual(updated_again.count(DETAILS["START_MARKER"]), 1)
        self.assertTrue(updated_again.startswith("# Weekly Release"))

    def test_rejects_unexpected_repository_and_negative_duration(self) -> None:
        with self.assertRaises(ValueError):
            DETAILS["build_details"](self.run, "2026-11-16T12:00:00Z", "other/repo")
        with self.assertRaises(ValueError):
            DETAILS["build_details"](self.run, "2026-11-16T09:59:59Z", REPOSITORY)

    def test_code_spans_cannot_be_closed_by_run_metadata(self) -> None:
        value = "feature" + chr(96) + "label"
        delimiter = chr(96) * 2
        self.assertEqual(DETAILS["code_span"](value), delimiter + value + delimiter)


if __name__ == "__main__":
    unittest.main()
