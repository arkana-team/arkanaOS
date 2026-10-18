# shellcheck shell=bash
# Use the uncolored host% / host# prompt common on traditional Unix systems.
case ${BASH_VERSION-} in
  ?*)
    case $- in
      *i*)
        if (( EUID == 0 )); then
          PS1='\h# '
        else
          PS1='\h% '
        fi
        ;;
    esac
    ;;
esac
