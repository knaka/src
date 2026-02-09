#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7f5d0a8-false}" && return 0; sourced_7f5d0a8=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

m2c() {
  mlr --pass-comments --m2c cat "$@"
}

case "${0##*/}" in
  (m2c.sh|m2c)
    set -o nounset -o errexit
    m2c "$@"
    ;;
esac
