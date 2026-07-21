#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8cac2e4-false}" && return 0; sourced_8cac2e4=true

# Display the date and time in ISO 8601 format.

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/time.sh
shift 2
cd "$1" || exit 1; shift

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ date-iso date_iso
then
  set -o nounset -o errexit
  date_iso "$@"
fi
