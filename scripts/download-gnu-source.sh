#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: download-gnu-source.sh OUTPUT URL" >&2
  exit 2
fi

output=$1
url=$2
temporary=$(mktemp "${output}.download.XXXXXX")
trap 'rm -f -- "$temporary"' EXIT

download() {
  curl -fsSL --retry 3 --retry-all-errors --retry-delay 2 \
    --connect-timeout 20 --max-time 600 -o "$temporary" "$1"
}

if download "$url"; then
  chmod 0644 "$temporary"
  mv -f -- "$temporary" "$output"
  exit 0
else
  primary_status=$?
fi

case "$url" in
  https://mirrors.ocf.berkeley.edu/gnu/*)
    fallback_url="https://ftp.gnu.org/gnu/${url#https://mirrors.ocf.berkeley.edu/gnu/}"
    ;;
  *)
    exit "$primary_status"
    ;;
esac

echo "GNU mirror download failed; retrying from the official GNU origin: $fallback_url" >&2
if download "$fallback_url"; then
  chmod 0644 "$temporary"
  mv -f -- "$temporary" "$output"
else
  exit "$?"
fi
