#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./build-update.sh --base-root DIR --target-root DIR \
  --signing-key FILE --public-key FILE [--output-dir DIR] \
  [--architecture x86_64] [--description TEXT]

Build a signed .aup delta with arkana-update-builder. Both roots must contain
consistent arkanaOS release metadata. Keep the signing key offline and private.
EOF
}

BASE_ROOT=
TARGET_ROOT=
OUTPUT_DIR="$(pwd)/output/updates"
SIGNING_KEY=
PUBLIC_KEY=
ARCHITECTURE=x86_64
DESCRIPTION=

while (($#)); do
  case "$1" in
    --base-root) BASE_ROOT=${2:?missing value for --base-root}; shift 2 ;;
    --target-root) TARGET_ROOT=${2:?missing value for --target-root}; shift 2 ;;
    --output-dir) OUTPUT_DIR=${2:?missing value for --output-dir}; shift 2 ;;
    --signing-key) SIGNING_KEY=${2:?missing value for --signing-key}; shift 2 ;;
    --public-key) PUBLIC_KEY=${2:?missing value for --public-key}; shift 2 ;;
    --architecture) ARCHITECTURE=${2:?missing value for --architecture}; shift 2 ;;
    --description) DESCRIPTION=${2:?missing value for --description}; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

for name in BASE_ROOT TARGET_ROOT SIGNING_KEY PUBLIC_KEY; do
  if [[ -z "${!name}" ]]; then
    echo "Missing required argument: ${name//_/-}" >&2
    usage >&2
    exit 2
  fi
done

BASE_ROOT=$(realpath -e -- "$BASE_ROOT")
TARGET_ROOT=$(realpath -e -- "$TARGET_ROOT")
SIGNING_KEY=$(realpath -e -- "$SIGNING_KEY")
PUBLIC_KEY=$(realpath -e -- "$PUBLIC_KEY")
OUTPUT_DIR=$(realpath -m -- "$OUTPUT_DIR")
python3 - "$OUTPUT_DIR" "$BASE_ROOT" "$TARGET_ROOT" <<'PY'
from pathlib import Path
import sys

output, *roots = map(Path, sys.argv[1:])
for root in roots:
    if output == root or output.is_relative_to(root):
        raise SystemExit(f"output directory must be outside root trees: {output}")
PY
mkdir -p -- "$OUTPUT_DIR"
OUTPUT_DIR=$(realpath -e -- "$OUTPUT_DIR")

for path in "$BASE_ROOT" "$TARGET_ROOT" "$SIGNING_KEY" "$PUBLIC_KEY" "$OUTPUT_DIR"; do
  if [[ "$path" == *,* ]]; then
    echo "Docker bind-mount paths may not contain commas: $path" >&2
    exit 2
  fi
done

HOST_CPUS=$(nproc)
AVAILABLE_RAM_MB=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
RAM_MB=${ARKANA_UPDATE_BUILD_RAM_MB:-2048}
CPUS=${ARKANA_UPDATE_BUILD_CPUS:-2}
ARKUP_GIT_REF=${ARKUP_GIT_REF:-01f6af6a2a6ab28052cb6846d8471e6b66fc8a8b}
if ! [[ "$RAM_MB" =~ ^[0-9]+$ ]] || ((RAM_MB < 512 || RAM_MB > AVAILABLE_RAM_MB)); then
  echo "ARKANA_UPDATE_BUILD_RAM_MB must be 512..${AVAILABLE_RAM_MB} MiB." >&2
  exit 2
fi
if ! [[ "$CPUS" =~ ^[0-9]+$ ]] || ((CPUS < 1 || CPUS > HOST_CPUS)); then
  echo "ARKANA_UPDATE_BUILD_CPUS must be 1..${HOST_CPUS}." >&2
  exit 2
fi
if ! [[ "$ARKUP_GIT_REF" =~ ^[0-9a-f]{40}$ ]]; then
  echo "ARKUP_GIT_REF must be a reviewed 40-character arkup commit SHA." >&2
  exit 2
fi

docker build \
  --memory="${RAM_MB}m" \
  --memory-swap="${RAM_MB}m" \
  --cpu-period=100000 \
  --cpu-quota="$((CPUS * 100000))" \
  --build-arg "ARKUP_GIT_REF=$ARKUP_GIT_REF" \
  -f Dockerfile.update-builder \
  -t arkana-update-builder .

# The commas are part of this single --tmpfs argument.
# shellcheck disable=SC2054
RUN_ARGS=(
  --rm
  --network none
  --read-only
  --tmpfs /tmp:rw,noexec,nosuid,size=128m
  --user 0:0
  --cap-drop ALL
  # Read-only inputs/key and one writable output mount bound the DAC override.
  --cap-add DAC_OVERRIDE
  --security-opt no-new-privileges
  --memory 512m
  --memory-swap 512m
  --cpus 1
  --mount "type=bind,src=$BASE_ROOT,dst=/inputs/base,readonly"
  --mount "type=bind,src=$TARGET_ROOT,dst=/inputs/target,readonly"
  --mount "type=bind,src=$SIGNING_KEY,dst=/keys/release.key,readonly"
  --mount "type=bind,src=$PUBLIC_KEY,dst=/keys/release.pub,readonly"
  --mount "type=bind,src=$OUTPUT_DIR,dst=/output"
)
COMMAND_ARGS=(
  --base-root /inputs/base
  --target-root /inputs/target
  --output-dir /output
  --signing-key /keys/release.key
  --public-key /keys/release.pub
  --architecture "$ARCHITECTURE"
)
if [[ -n "$DESCRIPTION" ]]; then
  COMMAND_ARGS+=(--description "$DESCRIPTION")
fi
USERNS_ARGS=()
ENGINE_VERSION=$(docker --version 2>&1 || true)
if [[ "$ENGINE_VERSION" == *[Pp]odman* ]]; then
  USERNS_ARGS+=(--userns=keep-id)
fi

docker run "${USERNS_ARGS[@]}" "${RUN_ARGS[@]}" arkana-update-builder "${COMMAND_ARGS[@]}"
