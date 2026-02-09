#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_9913f0e-false}" && return 0; sourced_9913f0e=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./task.sh
. ./tools.lib.sh
cd "$1" || exit 1; shift 2

run_mise() {
  if test $# = 0
  then
    mise tasks
  else
    local subcmd="$1"
    shift
    mise run "$subcmd" -- "$@"
  fi
}

t() {
  # Marker
  export executed_thru_t_bb789ec=true
  local dir="$PWD"
  while :
  do
    if is_root_dir "$dir"
    then
      echo "Reached to root directory." >&2
      return 1
    fi
    if test -r "$dir"/mise.toml
    then
      run_mise "$@"
      return
    elif ! is_windows && test -x "$dir"/task
    then
      "$dir"/task "$@"
      return
    elif is_windows && test -r "$dir"/task.cmd
    then
      "$dir"/task.cmd "$@"
      return
    fi
    dir="$dir"/..
  done
}

case "${0##*/}" in
  (t.sh|t)
    set -o nounset -o errexit
    t "$@"
    ;;
esac
