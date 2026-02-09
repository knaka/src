#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_144cc64-false}" && return 0; sourced_144cc64=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./tools.lib.sh
cd "$1"; shift 2

m2t() {
  mlr --pass-comments --m2t cat "$@"
}

case "${0##*/}" in
  (m2t.sh|m2t)
    set -o nounset -o errexit
    m2t "$@"
    ;;
esac
