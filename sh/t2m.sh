#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_d53a347-false}" && return 0; sourced_d53a347=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./miller.lib.sh
cd "$1"; shift 2

t2m() {
  mlr --pass-comments --t2m cat "$@"
}

case "${0##*/}" in
  (t2m.sh|t2m)
    set -o nounset -o errexit
    t2m "$@"
    ;;
esac
