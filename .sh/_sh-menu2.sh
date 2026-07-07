# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8324cce-false}" && return 0; sourced_8324cce=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/cui.lib.sh
shift 2
cd "$1" || exit 1; shift 2

set -o nounset -o errexit

filter_log() {
  awk '{printf "\r%s\n", $0}'
}

register_child_cleanup
while :
do
  date
  sleep 3
done | filter_log &
result=clear
while :
do
  result="$(gum choose --selected="$result" \
    "build" \
    "do something" \
    "clear" \
    "exit"
  )"
  case "$result" in
    (clear) clear;;
    (exit) break;;
    (*) ;;
  esac
done
