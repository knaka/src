#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f94640e-false}" && return 0; sourced_f94640e=true

cmd='grep'

test "${BB_GLOBBING+set}" != set && exec $cmd "$@"

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

grep() {
  # shellcheck disable=SC2086
  glob_and_run $cmd "$@"
}

case "${0##*/}" in
  (grep.sh|grep)
    set -o nounset -o errexit
    grep "$@"
    ;;
esac
