#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_008a5df-false}" && return 0; sourced_008a5df=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./gc.sh
. ./sc.sh
cd "$1"; shift 2

pb() {
  if test -t 0
  then
    gc
  else
    sc
  fi
}

case "${0##*/}" in
  (pb.sh|pb)
    set -o nounset -o errexit
    pb "$@"
    ;;
esac
