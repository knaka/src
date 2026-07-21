#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_92d8973-false}" && return 0; sourced_92d8973=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/time.sh
shift 2
cd "$1" || exit 1; shift 2

case "${0##*/}" in
  (touch-time-iso.sh|touch-time-iso)
    set -o nounset -o errexit
    set_last_mod_iso "$@"
    ;;
esac
