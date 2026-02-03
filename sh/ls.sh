#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3032e83-false}" && return 0; sourced_3032e83=true

cmd='ls'

test "${BB_GLOBBING+set}" != set && exec $cmd "$@"

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

ls() {
  # shellcheck disable=SC2086
  glob_and_run $cmd "$@"
}

case "${0##*/}" in
  (ls.sh|ls)
    set -o nounset -o errexit
    ls "$@"
    ;;
esac
