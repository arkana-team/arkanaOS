#!/usr/bin/env bash
set -euo pipefail
mkdir -p output src staging

# Build process can be uncapped. This will be faster but will use up more resources.
HOST_CPUS=$(nproc)
DEFAULT_CPUS=2
if [ "$HOST_CPUS" -lt "$DEFAULT_CPUS" ]; then
  DEFAULT_CPUS=$HOST_CPUS
fi
CPUS=${ARKANA_BUILD_CPUS:-$DEFAULT_CPUS}
if ! [[ "$CPUS" =~ ^[0-9]+$ ]] || [ "$CPUS" -lt 1 ] || [ "$CPUS" -gt "$HOST_CPUS" ]; then
  echo "ARKANA_BUILD_CPUS must be between 1 and $HOST_CPUS." >&2
  exit 1
fi
AVAILABLE_RAM_GB=$(awk '/MemAvailable/ {print int($2/1048576)}' /proc/meminfo)
SWAP=$(($(awk '/SwapTotal/ {print $2}' /proc/meminfo)/1048576))

echo "The system reports $HOST_CPUS CPUs, $AVAILABLE_RAM_GB GiB of available RAM, and $SWAP GiB of total swap."

if [ "$AVAILABLE_RAM_GB" -lt 2 ]; then
  echo "At least 2 GiB of available RAM is required to start the build safely." >&2
  exit 1
fi
DEFAULT_RAM_GB=$(( AVAILABLE_RAM_GB * 60 / 100 ))
if [ "$DEFAULT_RAM_GB" -gt 4 ]; then
  DEFAULT_RAM_GB=4
fi
CONTAINER_RAM=${ARKANA_BUILD_RAM_GB:-$DEFAULT_RAM_GB}
if ! [[ "$CONTAINER_RAM" =~ ^[0-9]+$ ]] || [ "$CONTAINER_RAM" -lt 1 ] || [ "$CONTAINER_RAM" -gt "$AVAILABLE_RAM_GB" ]; then
  echo "ARKANA_BUILD_RAM_GB must be a positive integer no larger than available RAM ($AVAILABLE_RAM_GB GiB)." >&2
  exit 1
fi
CONTAINER_SWAP=$(( SWAP * 80 / 100 ))
if [ "$CONTAINER_SWAP" -lt 4 ]; then
  CONTAINER_SWAP=4
fi

TOTAL_MEM_SWAP=$(( CONTAINER_RAM + CONTAINER_SWAP ))

echo "Will use $CONTAINER_RAM GB of memory, $CONTAINER_SWAP GB of swap ($TOTAL_MEM_SWAP GB total swap limit), and $CPUS CPUs to build arkanaOS."

echo "Starting build process. This will take several hours."
docker build -t arkana-builder .
docker run --rm -it --init \
  --cap-add=MKNOD \
  -v "$(pwd):/build/arkana" \
  -v "$(pwd)/.git:/build/arkana/.git:ro" \
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
