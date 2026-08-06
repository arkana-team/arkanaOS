#!/usr/bin/env bash
set -euo pipefail
mkdir -p output

# Build process can be uncapped. This will be faster but will use up more resources.
CPUS=$(nproc)
RAM=$(($(awk '/MemTotal/ {print $2}' /proc/meminfo)/1048576+1))
SWAP=$(($(awk '/SwapTotal/ {print $2}' /proc/meminfo)/1048576))

echo "The system reports $(nproc) CPUs, $RAM GB of RAM, and $SWAP GB of swap."

CONTAINER_RAM=$(( RAM * 80 / 100 ))
CONTAINER_SWAP=$(( SWAP * 80 / 100 ))
if [ "$CONTAINER_RAM" -lt 4 ]; then
  CONTAINER_RAM=4
fi
if [ "$CONTAINER_SWAP" -lt 4 ]; then
  CONTAINER_SWAP=4
fi

TOTAL_MEM_SWAP=$(( CONTAINER_RAM + CONTAINER_SWAP ))

echo "Will use $CONTAINER_RAM GB of memory, $CONTAINER_SWAP GB of swap ($TOTAL_MEM_SWAP GB total swap limit), and $CPUS CPUs to build arkanaOS."

echo "Starting build process. This will take several hours."
docker build -t arkana-builder .
docker run --rm -i --init \
  -v "$(pwd)/output:/build/arkana/output" \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  --memory=${CONTAINER_RAM}g \
  --memory-swap=${TOTAL_MEM_SWAP}g \
  --cpus="$CPUS" \
  arkana-builder

STAT=$?
if [ $STAT -eq 0 ]; then
  echo "Build complete. Check ./output for an ISO file."
fi
