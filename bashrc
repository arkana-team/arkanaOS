# shellcheck shell=bash
# Keep Bash's prompt as spare as a traditional Unix shell.
case ${BASH_VERSION-} in
  ?*)
    case $- in
      *i*) PS1='\$ ' ;;
    esac
