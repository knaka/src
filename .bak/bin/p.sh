#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_1fbf352-false}" && return 0; sourced_1fbf352=true

# Project management

# set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
# cd "$1"; shift 2

p() {
  git "$@"
}

case "${0##*/}" in
  (p.sh|p)
    set -o nounset -o errexit
    p "$@"
    ;;
esac
