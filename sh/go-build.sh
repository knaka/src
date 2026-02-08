#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_454f41d-false}" && return 0; sourced_454f41d=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./go.lib.sh
cd "$1"; shift 2

go_build() {
  # If the directory from which a command is executed is in a symlink and it appears outside of the workspace the IDE is working in, the debugger treats breakpoints as not set.
  push_dir "$(realpath "$PWD")"
  set -- go build -gcflags='all=-N -l' "$@"
  echo Executing: "$@" 2>&1
  "$@"
  pop_dir
}

case "${0##*/}" in
  (go-build.sh|go-build)
    set -o nounset -o errexit
    go_build "$@"
    ;;
esac
