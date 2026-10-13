#!/bin/sh
# Start the Solaris-style NsCDE session.

export NSCDE_PALETTE=Solyaris
export NSCDE_PALETTE_NCOLORS=4
xsetroot -cursor_name left_ptr 2>/dev/null || true
exec /usr/bin/nscde
elif command -v openbox >/dev/null 2>&1; then
    feh --bg-fill /usr/share/backgrounds/X11-bg.png 2>/dev/null || true
    xterm & exec openbox
fi
