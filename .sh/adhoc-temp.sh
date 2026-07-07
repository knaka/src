# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c2dabb4-false}" && return 0; sourced_c2dabb4=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
cd "$1" || exit 1; shift 2

temp_dir="$(mktemp -d)"

remove_temp_dir() {
  rm -fr "$temp_dir"
}

trap remove_temp_dir EXIT

adhoc_temp() {
  local file="$temp_dir"/hello.txt
  echo hello >"$file"
  echo 5cfe33b: "$file"
  cat -n "$file"
}

case "${0##*/}" in
  (adhoc-temp.sh|adhoc-temp)
    set -o nounset -o errexit
    adhoc_temp "$@"
    ;;
esac
