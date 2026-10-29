# shellcheck shell=bash
# Start NsCDE from the first local virtual console.
if [[ -r "$HOME/.bashrc" ]]; then
  . "$HOME/.bashrc"
fi

if [[ $- == *i* && -z ${DISPLAY:-} && -z ${SSH_TTY:-} && $(tty 2>/dev/null) == /dev/tty1 ]] \
  && command -v startx >/dev/null 2>&1; then
  startx
fi
