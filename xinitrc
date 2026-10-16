#!/bin/sh
# Start the Solaris-style NsCDE session.

export NSCDE_PALETTE=Solyaris
export NSCDE_PALETTE_NCOLORS=4
export FVWM_IS_FVWM3=1

# The live ISO keeps its boot medium mounted under /run/initramfs. Skip the
# interactive first-run wizard only in that disposable live session.
if [ -f /run/initramfs/bootdev/boot/rootfs.sfs ]; then
  export NSCDE_SKIP_FIRST_RUN=1
xsetroot -cursor_name left_ptr 2>/dev/null || true
exec /usr/bin/nscde
