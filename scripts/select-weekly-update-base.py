"""Choose all channel-compatible update bases, with an ISO bootstrap fallback."""

from __future__ import annotations

import argparse
import json
import re
import sys
from typing import Any

UPDATE_CLIENT_ASSET = "arkanaOS-update-client-system-update.txt"
ISO_RELEASE_ASSET = "arkana.iso"
SUPPORTED_RELEASE_TAG = re.compile(
    r"(?:nightly-[0-9]+|weekly-[0-9]+|v[1-9][0-9]*\.0-(?:(?:alpha[1-9][0-9]*|beta[1-9][0-9]*)-build|build)-[0-9]+)\Z"
)


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
        and SUPPORTED_RELEASE_TAG.fullmatch(tag) is not None
        and tag not in excluded_tags
        and isinstance(release.get("published_at"), str)
        and bool(release["published_at"])
    )


def select_bases(
    releases: list[Any],
    excluded_tags: set[str],
    channel: str,
    allow_empty_bootstrap: bool = False,
) -> list[str]:
    published = [
        release
        for release in releases
        if isinstance(release, dict) and is_published(release, excluded_tags)
    ]
    update_releases = [
        release
        for release in published
        if any(name.endswith(".aup") for name in release_assets(release))
        and ISO_RELEASE_ASSET in release_assets(release)
        and UPDATE_CLIENT_ASSET in release_assets(release)
    ]
    latest_update = max(update_releases, key=lambda release: release["published_at"]) if update_releases else None
    if channel == "weekly":
        weekly_updates = [
            release
            for release in update_releases
            if release["tag_name"].startswith("weekly-")
        ]
        if weekly_updates:
            # Monday needs both paths: the previous weekly build for users who
            # stayed on Mondays, and the latest scheduled build for users who
            # installed Sunday's nightly. Release assets persist independently
            # of Actions artifact retention.
            previous_weekly = max(weekly_updates, key=lambda release: release["published_at"])
            assert latest_update is not None
            return list(dict.fromkeys((previous_weekly["tag_name"], latest_update["tag_name"])))
    if latest_update is not None:
        return [latest_update["tag_name"]]

    bootstrap = [
        release
        for release in published
        if UPDATE_CLIENT_ASSET in release_assets(release)
        and ISO_RELEASE_ASSET in release_assets(release)
    ]
    if bootstrap:
        return [max(bootstrap, key=lambda release: release["published_at"])["tag_name"]]

    if allow_empty_bootstrap:
        return []
    raise ValueError("no system-update-capable update release or ISO is available")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--exclude-tag",
        action="append",
        default=[],
        help="exclude a release tag, such as the release currently being built",
    )
    parser.add_argument(
        "--channel",
        choices=("nightly", "weekly"),
        required=True,
        help="scheduled release channel that will consume the selected base",
    )
    parser.add_argument(
        "--allow-empty-bootstrap",
        action="store_true",
        help="allow the first scheduled ISO to seed an update-capable release base",
    )
    args = parser.parse_args()
    try:
        payload = json.load(sys.stdin)
        if not isinstance(payload, list):
            raise TypeError("release API input must be a JSON array")
        print(
            json.dumps(
                select_bases(
                    payload,
                    set(args.exclude_tag),
                    args.channel,
                    allow_empty_bootstrap=args.allow_empty_bootstrap,
                )
            )
        )
    except (json.JSONDecodeError, TypeError, ValueError) as error:
        print(f"select-weekly-update-base: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
