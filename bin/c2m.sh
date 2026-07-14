#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_2716efe-false}" && return 0; sourced_2716efe=true


test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ../.lib "$@"
. ../.lib/commands.sh
shift 2
cd "$1" || exit 1; shift

c2m() {
  mlr --pass-comments --c2m cat "$@"
}

case "${0##*/}" in
  (c2m.sh|c2m)
    set -o nounset -o errexit
    c2m "$@"
    ;;
esac
