#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_66b0bec-false}" && return 0; sourced_66b0bec=true

# Launch editor and block until it exits.

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
. ./launch-python.sh
cd "$1" || exit 1; shift 2

edw() {
  launch_python "$_APPDIR"/ed.py --wait "$@"
}

case "${0##*/}" in
  (edw.sh|edw)
    set -o nounset -o errexit
    edw "$@"
    ;;
esac
