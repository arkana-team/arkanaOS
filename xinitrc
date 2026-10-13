#!/bin/sh
# Start the Solaris-style NsCDE session.

export NSCDE_PALETTE=Solyaris
export NSCDE_PALETTE_NCOLORS=4
xsetroot -cursor_name left_ptr 2>/dev/null || true
exec /usr/bin/nscde
    xterm & exec openbox
fi
