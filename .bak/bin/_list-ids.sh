# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_25ab3c6-false}" && return 0; sourced_25ab3c6=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
. ./tolower.sh
cd "$1" || exit 1; shift 2

# 1b104cd
# 9e652d198c590709433d5
# fd21225

_list_ids() {
  grep -E -o -e '[^0-9a-fA-F][0-9a-fA-F]{7}' "$0" | sed -e 's/^.//' | tolower
}

case "${0##*/}" in
  (_list-ids.sh|_list-ids)
    set -o nounset -o errexit
    _list_ids "$@"
    ;;
esac
