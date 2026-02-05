#!/usr/bin/env bash
set -euo pipefail
mkdir -p output

# Build process can be uncapped. This will be faster but will use up more resources.
CPUS=$(nproc)  # Uncapped build
# CPUS=$((CPUS > 4 ? 4 : CPUS))  # Capped build
RAM=$(($(awk '/MemTotal/ {print $2}' /proc/meminfo)/1048576+1))

echo "The system reports $(nproc) CPUs and $RAM GB of RAM."

CONTAINER_RAM=16
if [ "$RAM" -lt 16 ]; then
  read -rep $'Warning: You may not have enough RAM to build arkanaOS.\nTry building anyways? [y/N] ' yn
  case $yn in
    [Yy]* ) true;;
    * ) false;;
  esac

  CONTAINER_RAM=$((CONTAINER_RAM/2))
fi

echo "Will use $CONTAINER_RAM GB of memory and $CPUS CPUs to build arkanaOS."

if [ "$CONTAINER_RAM" -gt "$RAM" ]; then
  echo "Note: $CONTAINER_RAM is >= system RAM, setting it to $RAM."
  CONTAINER_RAM="$RAM"
fi

echo "Starting build process. This will take several hours."
docker build -t arkana-builder .
docker run --rm -it --init \
  -v "$(pwd)/output:/build/arkana/output" \
  -e HOST_UID="$(id -u)" \
  -e HOST_GID="$(id -g)" \
  --memory-reservation=$((CONTAINER_RAM/2))g \
  --memory=${CONTAINER_RAM}g \
  --memory-swap=$((CONTAINER_RAM+4))g \
  --cpus="$CPUS" \
  arkana-builder

STAT=$?
if [ $STAT -eq 0 ]; then
  echo "Build complete. Check ./output for an ISO file."
fi
