# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3263e77-false}" && return 0; sourced_3263e77=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
cd "$1" || exit 1; shift 2



substr() {
  local _ids="589bfdd a65acec 772d9b7"
  local id
  for id in a65acec e6d0cf0
  do
    if _loaded "$id"
    then
      echo found "$id"
    else 
      echo not found "$id"
    fi
  done
}

case "${0##*/}" in
  (substr.sh|substr)
    set -o nounset -o errexit
    substr "$@"
    ;;
esac
