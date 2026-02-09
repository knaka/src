#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a3264fe-false}" && return 0; sourced_a3264fe=true

# Task runner

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR ./mise-tasks/ "$@"
. ./mise-tasks/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

task() {
  if test $# -eq 0
  then
    set -- tasks
  else
    local subcmd="$1"
    shift
    set -- run "$subcmd" -- "$@"
  fi
  
  mise "$@"
}

case "${0##*/}" in
  (task|task.sh)
    set -o nounset -o errexit
    task "$@"
    ;;
esac
