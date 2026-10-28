"""Choose the prior weekly Arkup release, with an initial ISO bootstrap fallback."""

from __future__ import annotations

import argparse
import json
import sys
from typing import Any

UPDATE_CLIENT_ASSET = "arkanaOS-update-client.txt"


def release_assets(release: dict[str, Any]) -> set[str]:
    assets = release.get("assets", [])
    if not isinstance(assets, list):
        return set()
    return {
        asset["name"]
        for asset in assets
        if isinstance(asset, dict) and isinstance(asset.get("name"), str)
    }


def is_published(release: dict[str, Any], excluded_tags: set[str]) -> bool:
    tag = release.get("tag_name")
    return (
        release.get("draft") is False
        and isinstance(tag, str)
        and bool(tag)
        and tag not in excluded_tags
        and isinstance(release.get("published_at"), str)
        and bool(release["published_at"])
    )


def select_base(releases: list[Any], excluded_tags: set[str]) -> str:
    published = [
        release
        for release in releases
        if isinstance(release, dict) and is_published(release, excluded_tags)
    ]
    weekly = [
        release
        for release in published
        if any(name.endswith(".aup") for name in release_assets(release))
        and any(name.endswith(".iso") for name in release_assets(release))
        and UPDATE_CLIENT_ASSET in release_assets(release)
    ]
    if weekly:
        return max(weekly, key=lambda release: release["published_at"])["tag_name"]

    bootstrap = [
        release
        for release in published
        if UPDATE_CLIENT_ASSET in release_assets(release)
        and any(name.endswith(".iso") for name in release_assets(release))
    ]
    if bootstrap:
        return max(bootstrap, key=lambda release: release["published_at"])["tag_name"]

    raise ValueError("no weekly update release or Arkup-capable ISO is available")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--exclude-tag",
        action="append",
        default=[],
        help="exclude a release tag, such as the release currently being built",
    )
    args = parser.parse_args()
    try:
        payload = json.load(sys.stdin)
        if not isinstance(payload, list):
            raise TypeError("release API input must be a JSON array")
        print(select_base(payload, set(args.exclude_tag)))
    except (json.JSONDecodeError, TypeError, ValueError) as error:
        print(f"select-weekly-update-base: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
