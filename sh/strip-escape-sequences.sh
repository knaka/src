#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4fa541a-false}" && return 0; sourced_4fa541a=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

case "${0##*/}" in
  (strip-escape-sequences.sh|strip-escape-sequences)
    set -o nounset -o errexit
    strip_escape_sequences "$@"
    ;;
esac
