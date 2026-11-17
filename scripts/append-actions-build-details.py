"""Add measured GitHub Actions run details to generated release notes."""

from __future__ import annotations

import argparse
import json
import re
import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import Any
from urllib.parse import urlsplit

START_MARKER = "<!-- actions-build-details:start -->"
END_MARKER = "<!-- actions-build-details:end -->"
GIT_SHA = re.compile(r"[0-9a-f]{40}\Z")
LOGIN = re.compile(r"[A-Za-z0-9](?:[A-Za-z0-9-]|\[bot\]){0,49}\Z")


def parse_time(value: Any, field: str) -> datetime:
    if not isinstance(value, str):
        raise TypeError(f"Actions run is missing {field}")
    try:
        parsed = datetime.fromisoformat(value)
    except ValueError as error:
        raise ValueError(f"Actions run has an invalid {field}") from error
    if parsed.tzinfo is None:
        raise ValueError(f"Actions run {field} must include a timezone")
    return parsed.astimezone(UTC)


def format_duration(seconds: int) -> str:
    if seconds < 0:
        raise ValueError("release publication time precedes the Actions run start")
    days, remainder = divmod(seconds, 86_400)
    hours, remainder = divmod(remainder, 3_600)
    minutes, seconds = divmod(remainder, 60)
    parts = []
    if days:
        parts.append(f"{days}d")
    if hours or days:
        parts.append(f"{hours}h")
    if minutes or hours or days:
        parts.append(f"{minutes}m")
    parts.append(f"{seconds}s")
    return " ".join(parts)


def code_text(value: Any, field: str) -> str:
    if not isinstance(value, str) or not value or "\n" in value or "\r" in value:
        raise ValueError(f"Actions run has an invalid {field}")
    return value


def code_span(value: str) -> str:
    longest_run = max((len(run) for run in re.findall(r"`+", value)), default=0)
    delimiter = "`" * (longest_run + 1)
    padding = " " if value.startswith(("`", " ")) or value.endswith(("`", " ")) else ""
    return f"{delimiter}{padding}{value}{padding}{delimiter}"


def build_details(
    run: dict[str, Any], ended_at: str, expected_repository: str
) -> str:
    run_id = run.get("id")
    run_number = run.get("run_number")
    run_attempt = run.get("run_attempt")
    if not all(type(value) is int and value > 0 for value in (run_id, run_number, run_attempt)):
        raise ValueError("Actions run identifiers must be positive integers")

    repository = run.get("repository")
    if not isinstance(repository, dict) or repository.get("full_name") != expected_repository:
        raise ValueError("Actions run repository does not match the release repository")
    url = run.get("html_url")
    expected_path = f"/{expected_repository}/actions/runs/{run_id}"
    parsed_url = urlsplit(url if isinstance(url, str) else "")
    if parsed_url.scheme != "https" or parsed_url.netloc != "github.com" or parsed_url.path != expected_path:
        raise ValueError("Actions run URL does not match its repository and run ID")

    started = parse_time(run.get("run_started_at") or run.get("created_at"), "start time")
    ended = parse_time(ended_at, "release publication time")
    duration = int((ended - started).total_seconds())
    actor = None
    for actor_data in (run.get("triggering_actor"), run.get("actor")):
        candidate = actor_data.get("login") if isinstance(actor_data, dict) else None
        if isinstance(candidate, str) and LOGIN.fullmatch(candidate) is not None:
            actor = candidate
            break
    if actor is None:
        raise ValueError("Actions run has no verifiable triggering actor")
    event = code_text(run.get("event"), "event")
    branch = code_text(run.get("head_branch"), "branch")
    workflow = code_text(run.get("name"), "workflow name")
    commit = run.get("head_sha")
    if not isinstance(commit, str) or GIT_SHA.fullmatch(commit) is None:
        raise ValueError("Actions run has an invalid source commit")

    return "\n".join(
        (
            START_MARKER,
            "### GitHub Actions build",
            f"- Workflow: [{workflow}]({url})",
            f"- Run: {code_span(f'#{run_number}')} (attempt {code_span(str(run_attempt))})",
            f"- Trigger: {code_span(event)}",
            f"- Triggered by: {code_span(f'@{actor}')}",
            f"- Commit: [`{commit[:12]}`](https://github.com/{expected_repository}/commit/{commit})",
            f"- Branch: {code_span(branch)}",
            f"- Started: {code_span(started.isoformat(timespec='seconds'))}",
            f"- Released: {code_span(ended.isoformat(timespec='seconds'))}",
            f"- Build duration through release publication: {code_span(format_duration(duration))}",
            END_MARKER,
        )
    )


def with_build_details(notes: str, details: str) -> str:
    start = notes.find(START_MARKER)
    end = notes.find(END_MARKER)
    if (start == -1) != (end == -1) or (start != -1 and end < start):
        raise ValueError("release notes contain an incomplete Actions metadata section")
    if start != -1:
        end += len(END_MARKER)
        notes = notes[:start].rstrip() + notes[end:]
    return f"{notes.rstrip()}\n\n{details}\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run-json", required=True, type=Path)
    parser.add_argument("--notes", required=True, type=Path)
    parser.add_argument("--ended-at", required=True)
    parser.add_argument("--repository", required=True)
    arguments = parser.parse_args()
    try:
        run = json.loads(arguments.run_json.read_text(encoding="utf-8"))
        notes = arguments.notes.read_text(encoding="utf-8")
        if not isinstance(run, dict):
            raise TypeError("Actions run metadata must be a JSON object")
        details = build_details(run, arguments.ended_at, arguments.repository)
        sys.stdout.write(with_build_details(notes, details))
    except (OSError, UnicodeError, json.JSONDecodeError, TypeError, ValueError) as error:
        parser.error(str(error))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
