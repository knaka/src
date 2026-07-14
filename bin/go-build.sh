#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_454f41d-false}" && return 0; sourced_454f41d=true

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/commands.sh
shift 2
cd "$1" || exit 1; shift

go_build() {
  # If the directory from which a command is executed is in a symlink and it appears outside of the workspace the IDE is working in, the debugger treats breakpoints as not set.
  push_dir "$(realpath "$PWD")"
  set -- build -gcflags='all=-N -l' "$@"
  echo Executing: go "$@" 2>&1
  go "$@"
  pop_dir
}

case "${0##*/}" in
  (go-build.sh|go-build)
    set -o nounset -o errexit
    go_build "$@"
    ;;
esac
