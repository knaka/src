#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_1fbf352-false}" && return 0; sourced_1fbf352=true

# Project management

# set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
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
