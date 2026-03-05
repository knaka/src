# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7738fcb-false}" && return 0; sourced_7738fcb=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
cd "$1" || exit 1; shift 2

# XTERM – Terminal emulator for the X Window System https://invisible-island.net/xterm/xterm.html
# How to change the title of an xterm https://tldp.org/HOWTO/Xterm-Title.html
# How to change the title of an xterm: Dynamic titles https://tldp.org/HOWTO/Xterm-Title-3.html

set_terminal_title() {
  printf "\033]0;%s\007" "$1"
}

case "${0##*/}" in
  (set-terminal-title.sh|set-terminal-title)
    set -o nounset -o errexit
    set_terminal_title "$@"
    ;;
esac
