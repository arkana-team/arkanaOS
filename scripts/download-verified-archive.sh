#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "usage: download-verified-archive.sh OUTPUT SHA256 PRIMARY_URL FALLBACK_URL" >&2
  exit 2
fi

output=$1
expected_sha256=$2
primary_url=$3
fallback_url=$4
max_time=${ARKANA_SOURCE_DOWNLOAD_MAX_TIME:-1800}

if ! [[ "$expected_sha256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "expected SHA-256 must be 64 lowercase hexadecimal characters" >&2
  exit 2
fi
if ! [[ "$max_time" =~ ^[1-9][0-9]*$ ]]; then
  echo "ARKANA_SOURCE_DOWNLOAD_MAX_TIME must be a positive integer" >&2
  exit 2
fi
if ! [[ "$primary_url" == https://* && "$fallback_url" == https://* &&
        "$primary_url" != "$fallback_url" ]]; then
  echo "primary and fallback URLs must be distinct HTTPS URLs" >&2
  exit 2
fi
if [[ -L "$output" ]]; then
  echo "refusing to replace a symlinked archive path: $output" >&2
  exit 1
fi
if [[ -e "$output" && ! -f "$output" ]]; then
  echo "refusing to replace a non-file archive path: $output" >&2
  exit 1
fi

verify_archive() {
  local archive=$1
  [[ -f "$archive" && ! -L "$archive" ]] &&
    printf '%s  %s\n' "$expected_sha256" "$archive" |
      sha256sum --check --status
}

if verify_archive "$output"; then
  exit 0
fi

temporary=$(mktemp "$output.download.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT

download_and_verify() {
  local url=$1
  if ! curl -fsSL --retry 3 --retry-all-errors --retry-delay 2 \
    --connect-timeout 20 --max-time "$max_time" \
    -o "$temporary" "$url"; then
    return 1
  fi
  if ! verify_archive "$temporary"; then
    echo "SHA-256 verification failed for archive from $url" >&2
    return 1
  fi
  return 0
}

if ! download_and_verify "$primary_url"; then
  echo "Primary archive fetch failed; trying the verified fallback URL" >&2
  if ! download_and_verify "$fallback_url"; then
    echo "unable to download a SHA-256-verified archive from either URL" >&2
    exit 1
  fi
fi

chmod 0644 "$temporary"
mv -f -- "$temporary" "$output"
