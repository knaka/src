#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3ddfb53-false}" && return 0; sourced_3ddfb53=true

# Edit in raw mode.

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
. ./launch-python.sh
cd "$1" || exit 1; shift 2

edr() {
  launch_python "$_APPDIR"/ed.py --raw "$@"
}

case "${0##*/}" in
  (edr.sh|edr)
    set -o nounset -o errexit
    edr "$@"
    ;;
esac
