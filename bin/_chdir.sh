# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_fa54274-false}" && return 0; sourced_fa54274=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
cd "$1" || exit 1; shift 2

_chdir() {
  cd "$1"
  shift
  exec sh "$@"
}

case "${0##*/}" in
  (_chdir.sh|_chdir)
    set -o nounset -o errexit
    _chdir "$@"
    ;;
esac
