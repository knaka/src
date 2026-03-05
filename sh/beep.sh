# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f24502f-false}" && return 0; sourced_f24502f=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
cd "$1" || exit 1; shift 2

# Emit a terminal bell (BEL) character to trigger an audible or visual alert.
beep() {
  printf '\a'
}

case "${0##*/}" in
  (beep.sh|beep)
    set -o nounset -o errexit
    beep "$@"
    ;;
esac
