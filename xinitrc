#!/bin/sh
# Open a desktop session and start Window Maker
# Arkana provides X11 with Window Maker as the window manager

xsetroot -cursor_name left_ptr 2>/dev/null || true
if command -v feh >/dev/null 2>&1 && [ -f /usr/share/backgrounds/X11-bg.png ]; then
    feh --bg-fill /usr/share/backgrounds/X11-bg.png 2>/dev/null || true
else
    xsetroot -solid "#0f172a" 2>/dev/null || true
fi

if command -v wmaker >/dev/null 2>&1; then
    exec wmaker
elif command -v openbox >/dev/null 2>&1; then
    feh --bg-fill /usr/share/backgrounds/X11-bg.png 2>/dev/null || true
    xterm & exec openbox
fi
