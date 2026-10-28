"""Raise the local build counter to the newest published arkanaOS release."""

from __future__ import annotations

import argparse
import os
import re
import sys
import tempfile
from pathlib import Path

BUILD_TAG_PATTERNS = (
    re.compile(r"nightly-([0-9]+)"),
    re.compile(r"weekly-([0-9]+)"),
    re.compile(r"nightly-build-([0-9]+)"),
    re.compile(r"nightly-[0-9]{8}-build-([0-9]+)"),
    re.compile(r"v[1-9][0-9]*\.0-(?:alpha[1-9][0-9]*|beta[1-9][0-9]*)-build-([0-9]+)"),
    re.compile(r"v[1-9][0-9]*\.0-build-([0-9]+)"),
)
MAX_BUILD_NUMBER = 9_223_372_036_854_775_806


def parse_build_number(value: str, *, source: str) -> int:
    if not re.fullmatch(r"[0-9]+", value):
        raise ValueError(f"{source} must contain a non-negative decimal build number")
    if len(value) > 19:
        raise ValueError(f"{source} exceeds the supported build number range")
    number = int(value)
    if number > MAX_BUILD_NUMBER:
        raise ValueError(f"{source} exceeds the supported build number range")
    return number


def release_build_number(tag: str) -> int | None:
    for pattern in BUILD_TAG_PATTERNS:
        match = pattern.fullmatch(tag)
        if match:
            return parse_build_number(match.group(1), source=f"release tag {tag!r}")
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build-file", required=True, type=Path)
    arguments = parser.parse_args()

    build_file: Path = arguments.build_file
    try:
        current = parse_build_number(
            build_file.read_text(encoding="ascii").strip(), source=str(build_file)
        )
        published_builds = [
            number
            for line in sys.stdin
            if (number := release_build_number(line.strip())) is not None
        ]
    except (OSError, UnicodeError, ValueError) as error:
        parser.error(str(error))
    latest_release = max(published_builds, default=0)
    seeded = max(current, latest_release)

    if seeded > current:
        original_mode = build_file.stat().st_mode & 0o7777
        temporary_path: Path | None = None
        try:
            with tempfile.NamedTemporaryFile(
                mode="w",
                encoding="ascii",
                dir=build_file.parent,
                prefix=f".{build_file.name}.",
                delete=False,
            ) as temporary_file:
                temporary_path = Path(temporary_file.name)
                temporary_file.write(f"{seeded}\n")
            os.chmod(temporary_path, original_mode)
            os.replace(temporary_path, build_file)
        finally:
            if temporary_path is not None:
                temporary_path.unlink(missing_ok=True)

    print(
        "Build counter baseline: "
        f"checked-in={current}, latest-published={latest_release}, seeded={seeded}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
