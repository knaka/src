#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_454f41d-false}" && return 0; sourced_454f41d=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./go.lib.sh
cd "$1"; shift 2

go_build() {
  # If the directory from which a command is executed is in a symlink and it appears outside of the workspace the IDE is working in, the debugger treats breakpoints as not set.
  push_dir "$(realpath "$PWD")"
  local arg
  local found=false
  for arg in "$@"
  do
    shift
    test "$arg" = "--" && found=true
    ! "$found" && set -- "$@" "$arg"
  done
  echo go build -gcflags='all=-N -l' "$@" 2>&1
  go build -gcflags='all=-N -l' "$@"
  pop_dir
}

case "${0##*/}" in
  (go-build.sh|go-build)
    set -o nounset -o errexit
    go_build "$@"
    ;;
esac
