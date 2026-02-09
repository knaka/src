#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_2716efe-false}" && return 0; sourced_2716efe=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./tools.lib.sh
cd "$1"; shift 2

c2m() {
  mlr --pass-comments --c2m cat "$@"
}

case "${0##*/}" in
  (c2m.sh|c2m)
    set -o nounset -o errexit
    c2m "$@"
    ;;
esac
