#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_20bf1eb-false}" && return 0; sourced_20bf1eb=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/cui.lib.sh
shift 2
cd "$1" || exit 1; shift 2

set -o nounset -o errexit

register_child_cleanup
while :
do
  date
  sleep 3
done &
result=bar
while :
do
  result="$(hchoose --header="Selection:" --selected="$result" \
    "Browse the site" \
    "Clear" \
    "Build it" \
    "Exit"
  )"
  case "$result" in
    (Clear) clear;;
    (Exit) break;;
    (*) ;;
  esac
done
