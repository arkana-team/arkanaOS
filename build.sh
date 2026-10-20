#!/usr/bin/env bash
set -euo pipefail
mkdir -p output src staging

# Keep builds resource-bounded by default; ARKANA_BUILD_* variables tune the limits.
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
AVAILABLE_RAM_MB=$(awk '/MemAvailable/ {print int($2/1024)}' /proc/meminfo)
AVAILABLE_SWAP_MB=$(awk '/SwapFree/ {print int($2/1024)}' /proc/meminfo)

echo "The system reports $HOST_CPUS CPUs, $AVAILABLE_RAM_MB MiB of available RAM, and $AVAILABLE_SWAP_MB MiB of free swap."

if [ "$AVAILABLE_RAM_MB" -lt 2048 ]; then
  echo "At least 2048 MiB of available RAM is required to start the build safely." >&2
  exit 1
fi
DEFAULT_RAM_MB=$(( AVAILABLE_RAM_MB * 60 / 100 ))
if [ "$DEFAULT_RAM_MB" -gt 4096 ]; then
  DEFAULT_RAM_MB=4096
fi
CONTAINER_RAM_MB=${ARKANA_BUILD_RAM_MB:-$DEFAULT_RAM_MB}
if ! [[ "$CONTAINER_RAM_MB" =~ ^[0-9]+$ ]] || [ "$CONTAINER_RAM_MB" -lt 512 ] || [ "$CONTAINER_RAM_MB" -gt "$AVAILABLE_RAM_MB" ]; then
  echo "ARKANA_BUILD_RAM_MB must be at least 512 and no larger than available RAM ($AVAILABLE_RAM_MB MiB)." >&2
  exit 1
fi
DEFAULT_SWAP_MB=$(( AVAILABLE_SWAP_MB / 2 ))
if [ "$DEFAULT_SWAP_MB" -gt 2048 ]; then
  DEFAULT_SWAP_MB=2048
fi
CONTAINER_SWAP_MB=${ARKANA_BUILD_SWAP_MB:-$DEFAULT_SWAP_MB}
if ! [[ "$CONTAINER_SWAP_MB" =~ ^[0-9]+$ ]] || [ "$CONTAINER_SWAP_MB" -gt "$AVAILABLE_SWAP_MB" ]; then
  echo "ARKANA_BUILD_SWAP_MB must be a non-negative integer no larger than free swap ($AVAILABLE_SWAP_MB MiB)." >&2
  exit 1
fi

TOTAL_MEM_SWAP_MB=$(( CONTAINER_RAM_MB + CONTAINER_SWAP_MB ))

echo "Will use $CONTAINER_RAM_MB MiB of memory, $CONTAINER_SWAP_MB MiB of swap ($TOTAL_MEM_SWAP_MB MiB total limit), and $CPUS CPUs to build arkanaOS."

echo "Starting build process. This will take several hours."
docker build --cpu-quota="$((CPUS * 100000))" \
  --memory="${CONTAINER_RAM_MB}m" \
  --memory-swap="${TOTAL_MEM_SWAP_MB}m" \
  -t arkana-builder .
docker run --rm -it --init \
  --cap-add=MKNOD \
  -v "$(pwd):/build/arkana" \
  -v "$(pwd)/.git:/build/arkana/.git:ro" \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  -e ARKANA_BUILD_NUMBER \
  -e THREADS="$CPUS" \
  -e NINJAJOBS="$CPUS" \
  --memory=${CONTAINER_RAM_MB}m \
  --memory-swap=${TOTAL_MEM_SWAP_MB}m \
  --cpus="$CPUS" \
  arkana-builder

STAT=$?
if [ $STAT -eq 0 ]; then
  echo "Build complete. Check ./output for an ISO file."
fi
