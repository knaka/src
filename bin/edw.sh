#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_66b0bec-false}" && return 0; sourced_66b0bec=true

# Launch editor and block until it exits.

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
. ./ed.sh
shift 2
cd "$1" || exit 1; shift

edw() {
  ed --wait "$@"
}

case "${0##*/}" in
  (edw.sh|edw)
    set -o nounset -o errexit
    edw "$@"
    ;;
esac
