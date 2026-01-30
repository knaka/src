#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_91e0e8d-false}" && return 0; sourced_91e0e8d=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
cd "$1"; shift 2

ppd() {
  echo "$PPD"
}

case "${0##*/}" in
  (ppd.sh|ppd)
    set -o nounset -o errexit
    ppd "$@"
    ;;
esac
