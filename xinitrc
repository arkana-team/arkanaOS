#!/bin/sh
# Open a desktop session and start a terminal emulator
# May 2025: Arkana provides X11!
# August 2025: The desktop wallpaper actually works!

xsetroot -cursor_name left_ptr 2>/dev/null || true
if command -v feh >/dev/null 2>&1 && [ -f /usr/share/backgrounds/X11-bg.png ]; then
    feh --bg-fill /usr/share/backgrounds/X11-bg.png 2>/dev/null || true
else
    xsetroot -solid "#0f172a" 2>/dev/null || true
fi

if command -v twm >/dev/null 2>&1; then
    xterm &
    exec twm
elif command -v openbox >/dev/null 2>&1; then
    feh --bg-fill /usr/share/backgrounds/X11-bg.png 2>/dev/null || true
    xterm & exec openbox
fi
