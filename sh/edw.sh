#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_66b0bec-false}" && return 0; sourced_66b0bec=true

# Launch editor and block until it exits.

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./ed.sh
cd "$1" || exit 1; shift 2

edw() {
  ed --wait "$@"
}

case "${0##*/}" in
  (edw.sh|edw)
    set -o nounset -o errexit
    edw "$@"
    ;;
esac
