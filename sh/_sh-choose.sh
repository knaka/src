# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_6175b6c-false}" && return 0; sourced_6175b6c=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/cui.lib.sh
shift 2
cd "$1" || exit 1; shift 2

_sh_choose() {
  local result="baz"
  while :
  do
    result="$(choose --label-delimiter=":" --selected="$result" \
      "Foo Foo:foo" \
      "Bar Bar:bar" \
      "Baz Baz:baz" \
      "Exit:exit"
    )"
    test "$result" = "exit" && break
  done
}

case "${0##*/}" in
  (_sh-choose.sh|_sh-choose)
    set -o nounset -o errexit
    _sh_choose "$@"
    ;;
esac
