#!/usr/bin/env bash
set -euo pipefail

container_root=${ARKANA_CONTAINER_ROOT:-/}
cgroup_file=${ARKANA_CGROUP_FILE:-/proc/1/cgroup}

if [[ -e "$container_root/.dockerenv" || -e "$container_root/run/.containerenv" ]]; then
    echo true
    exit 0
fi

case "${container:-}" in
    ""|host|none) ;;
    *)
        echo true
        exit 0
        ;;
esac

if [[ -r "$cgroup_file" ]] && grep -Eiq '(docker|containerd|kubepods|podman|libpod|lxc|machine\.slice)' "$cgroup_file"; then
    echo true
else
    echo false
fi
