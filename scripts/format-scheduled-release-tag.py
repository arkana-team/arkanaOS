"""Format the shared dated GitHub tag for a scheduled or manual nightly build."""

from __future__ import annotations

import argparse
import json
import re
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


def release_tag(prefix: str, build_number: str, run: dict[str, Any]) -> str:
    if prefix != "nightly":
        raise ValueError("developer release prefix must be nightly")
    if not re.fullmatch(r"[1-9][0-9]*", build_number):
        raise ValueError("build number must be a positive decimal integer")
    started_at = run.get("run_started_at") or run.get("created_at")
    if not isinstance(started_at, str):
        raise TypeError("Actions run has no start timestamp")
    try:
        started = datetime.fromisoformat(started_at)
    except ValueError as error:
        raise ValueError("Actions run start timestamp is invalid") from error
    if started.tzinfo is None:
        raise ValueError("Actions run start timestamp must include a timezone")
    build_date = started.astimezone(UTC).strftime("%Y%m%d")
    return f"{prefix}-{build_date}-build-{build_number}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prefix", required=True, choices=("nightly",))
    parser.add_argument("--build-number", required=True)
    parser.add_argument("--run-json", required=True, type=Path)
    arguments = parser.parse_args()
    try:
        run = json.loads(arguments.run_json.read_text(encoding="utf-8"))
        if not isinstance(run, dict):
            raise TypeError("Actions run metadata must be a JSON object")
        print(release_tag(arguments.prefix, arguments.build_number, run))
    except (OSError, UnicodeError, json.JSONDecodeError, TypeError, ValueError) as error:
        parser.error(str(error))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
