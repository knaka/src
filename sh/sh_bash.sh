# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ c991879 && return 0

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./sh_bash.lib.sh
shift 2
cd "$1" || exit 1; shift 2

sh_bash() {
  echo "Function \"sh_bash\" is not implemented yet."
}

case "${0##*/}" in
  (sh_bash.sh|sh_bash)
    set -o nounset -o errexit
    sh_bash "$@"
    ;;
esac
