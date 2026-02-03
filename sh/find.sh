#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_6fa61f0-false}" && return 0; sourced_6fa61f0=true

cmd='find'

test "${BB_GLOBBING+set}" != set && exec $cmd "$@"

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

find() {
  # shellcheck disable=SC2086
  # glob_and_run $cmd "$@"
  exec $cmd "$@"
}

case "${0##*/}" in
  (find.sh|find)
    set -o nounset -o errexit
    find "$@"
    ;;
esac
