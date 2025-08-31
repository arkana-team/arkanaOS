#!/bin/sh
# Open a desktop session and start a terminal emulator
# May 2025: Arkana provides X11!
# August 2025: The desktop wallpaper actually works!

feh --bg-fill /usr/share/backgrounds/X11-bg.png
xterm & exec openbox
