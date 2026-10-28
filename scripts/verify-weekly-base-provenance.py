#!/usr/bin/env python3
"""Verify that a weekly update base is a successful, retained Actions artifact."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

MARKER_VALUES = {
    "arkup-client": "/usr/bin/arkup",
    "base-sequence": "1",
    "system-update": "1",
}
RELEASE_TAG = re.compile(
    r"(?:nightly-(?P<nightly_build>[0-9]+)|"
    r"v[1-9][0-9]*\.0-(?:(?:alpha[1-9][0-9]*|beta[1-9][0-9]*)-build|build)-"
    r"(?P<release_build>[0-9]+))\Z"
)
GIT_SHA = re.compile(r"[0-9a-f]{40}\Z")


class ProvenanceError(ValueError):
    """The release does not identify a trusted, retained workflow artifact."""


def parse_marker(text: str) -> dict[str, str]:
    values: dict[str, str] = {}
    for line in text.splitlines():
        if not line or "=" not in line:
            raise ProvenanceError("system-update marker has an invalid line")
        key, value = line.split("=", 1)
        if not key or not value or key in values:
            raise ProvenanceError(
                "system-update marker has an empty or duplicate field"
            )
        values[key] = value

    expected_keys = set(MARKER_VALUES) | {"source-run-id", "source-sha", "build-number"}
    if set(values) != expected_keys:
        raise ProvenanceError(
            "system-update marker fields do not match the supported format"
        )
    if any(values.get(key) != value for key, value in MARKER_VALUES.items()):
        raise ProvenanceError(
            "system-update marker does not declare the supported client"
        )
    if not re.fullmatch(r"[1-9][0-9]*", values["source-run-id"]):
        raise ProvenanceError("system-update marker has an invalid source run id")
    if not GIT_SHA.fullmatch(values["source-sha"]):
        raise ProvenanceError("system-update marker has an invalid source commit")
    if not re.fullmatch(r"[0-9]+", values["build-number"]):
        raise ProvenanceError("system-update marker has an invalid build number")
    return values


def release_artifact_name(release_tag: str) -> tuple[str, str]:
    match = RELEASE_TAG.fullmatch(release_tag)
    if match is None:
        raise ProvenanceError("release tag does not use a supported arkanaOS format")
    build_number = match.group("nightly_build") or match.group("release_build")
    version = release_tag.removeprefix("v")
    return f"arkanaOS-{version}-iso", build_number


def verify_base_provenance(
    *,
    release_tag: str,
    tag_sha: str,
    marker_text: str,
    run: dict[str, Any],
    artifacts_payload: Any,
    repository: str,
    default_branch: str,
    workflow_id: str,
) -> dict[str, str]:
    artifact_name, expected_build = release_artifact_name(release_tag)
    marker = parse_marker(marker_text)
    if marker["build-number"] != expected_build:
        raise ProvenanceError(
            "system-update marker build number does not match the release tag"
        )
    if not isinstance(run, dict):
        raise ProvenanceError("source run response is invalid")
    if (
        not isinstance(tag_sha, str)
        or not GIT_SHA.fullmatch(tag_sha)
        or tag_sha != marker["source-sha"]
    ):
        raise ProvenanceError(
            "release tag does not point to the marker's source commit"
        )

    run_id = marker["source-run-id"]
    if (
        str(run.get("id")) != run_id
        or str(run.get("workflow_id")) != workflow_id
        or not isinstance(run.get("repository"), dict)
        or run["repository"].get("full_name") != repository
        or not isinstance(run.get("head_repository"), dict)
        or run["head_repository"].get("full_name") != repository
        or run.get("head_branch") != default_branch
        or run.get("head_sha") != marker["source-sha"]
        or run.get("event") not in {"schedule", "workflow_dispatch"}
        or run.get("status") != "completed"
        or run.get("conclusion") != "success"
    ):
        raise ProvenanceError(
            "source run is not a successful default-branch Run All build"
        )

    if isinstance(artifacts_payload, dict):
        artifacts = artifacts_payload.get("artifacts")
    else:
        artifacts = artifacts_payload
    if not isinstance(artifacts, list):
        raise ProvenanceError("source run artifact response is invalid")
    matching = [
        artifact
        for artifact in artifacts
        if isinstance(artifact, dict)
        and artifact.get("name") == artifact_name
        and artifact.get("expired") is False
        and isinstance(artifact.get("id"), int)
        and artifact["id"] > 0
        and isinstance(artifact.get("size_in_bytes"), int)
        and artifact["size_in_bytes"] > 0
    ]
    if len(matching) != 1:
        raise ProvenanceError("source run must have exactly one retained ISO artifact")

    return {
        "run_id": run_id,
        "artifact_name": artifact_name,
        "artifact_id": str(matching[0]["id"]),
        "build_number": expected_build,
        "source_sha": marker["source-sha"],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--release-tag", required=True)
    parser.add_argument("--tag-sha", required=True)
    parser.add_argument("--marker", required=True, type=Path)
    parser.add_argument("--run-json", required=True, type=Path)
    parser.add_argument("--artifacts-json", required=True, type=Path)
    parser.add_argument("--repository", required=True)
    parser.add_argument("--default-branch", required=True)
    parser.add_argument("--workflow-id", required=True)
    args = parser.parse_args()

    try:
        result = verify_base_provenance(
            release_tag=args.release_tag,
            tag_sha=args.tag_sha,
            marker_text=args.marker.read_text(encoding="utf-8"),
            run=json.loads(args.run_json.read_text(encoding="utf-8")),
            artifacts_payload=json.loads(
                args.artifacts_json.read_text(encoding="utf-8")
            ),
            repository=args.repository,
            default_branch=args.default_branch,
            workflow_id=args.workflow_id,
        )
    except (OSError, json.JSONDecodeError, TypeError, ProvenanceError) as error:
        print(f"verify-weekly-base-provenance: {error}", file=sys.stderr)
        return 1

    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
