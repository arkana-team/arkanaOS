#!/usr/bin/env bash
set -euo pipefail
mkdir -p output

CPUS=$(nproc)
if [ "$CPUS" -ge 4 ]; then
	CPUS=4
fi

docker build -t arkana-builder .
docker run --rm -it --init \
  -v "$(pwd)/output:/build/arkana/output" \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  --memory-reservation=8g \
  --memory=16g \
  --memory-swap=16g \
  --cpus="$CPUS" \
  arkana-builder
