#!/usr/bin/env sh
set -- _BIN_SET_TERMINAL_TITLE_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

# XTERM – Terminal emulator for the X Window System https://invisible-island.net/xterm/xterm.html
# How to change the title of an xterm https://tldp.org/HOWTO/Xterm-Title.html
# How to change the title of an xterm: Dynamic titles https://tldp.org/HOWTO/Xterm-Title-3.html

set_terminal_title() {
  printf "\033]0;%s\007" "$1"
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.set-terminal-title.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  set_terminal_title "$@"
fi
