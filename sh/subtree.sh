#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_d63b0f1-false}" && return 0; sourced_d63b0f1=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./task.sh
  init_temp_dir
. ./subtree.lib.sh
cd "$1"; shift 2

show_help() {
  echo "Usage: subtree <add|remove|push|pull> [args...]" >&2
}

subtree() {
  if test "${1+set}" != set
  then
    show_help
    return 1
  fi
  if test "$1" = "-h" -o "$1" = "--help"
  then
    show_help
    return 0
  fi
  local cmd="$1"
  shift
  local task_fn=subcmd_subtree__"$cmd"
  "$task_fn" "$@"
}

case "${0##*/}" in
  (subtree.sh|subtree)
    set -o nounset -o errexit
    subtree "$@"
    ;;
esac
