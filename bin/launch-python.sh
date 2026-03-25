# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_daf0894-false}" && return 0; sourced_daf0894=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
. ./mise
cd "$1" || exit 1; shift 2

launch_python() {
  cd "$_APPDIR" || exit 1
  local dir="$OLDPWD"
  mise exec --cd="$dir" -- python "$@"
  cd "$dir" || exit 1
}

case "${0##*/}" in
  (launch-python.sh|launch-python)
    set -o nounset -o errexit
    launch_python "$@"
    ;;
esac
