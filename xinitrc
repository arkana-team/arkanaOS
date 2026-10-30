#!/bin/sh
# Start the Solaris-style NsCDE session.

export NSCDE_PALETTE=Solyaris
export NSCDE_PALETTE_NCOLORS=4
export FVWM_IS_FVWM3=1

# The live ISO keeps its boot medium mounted under /run/initramfs. Skip the
# interactive first-run wizard only in that disposable live session.
if [ -f /run/initramfs/bootdev/boot/rootfs.sfs ]; then
  export NSCDE_SKIP_FIRST_RUN=1
  if command -v fvwm-root >/dev/null 2>&1 && [ -r "$HOME/.NsCDE/backer/Desk1-Solyaris.pm" ]; then
    fvwm-root --retain-pixmap "$HOME/.NsCDE/backer/Desk1-Solyaris.pm" 2>/dev/null || true
  fi
fi

if command -v xrdb >/dev/null 2>&1; then
  if [ -r /etc/X11/Xresources.d/arkanaOS ]; then
    xrdb -merge /etc/X11/Xresources.d/arkanaOS 2>/dev/null || true
  fi
  if [ -r "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources" 2>/dev/null || true
  fi
fi

xsetroot -cursor_name left_ptr 2>/dev/null || true
exec /usr/bin/nscde
