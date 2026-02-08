#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b8dd816-false}" && return 0; sourced_b8dd816=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./task.sh
  init_temp_dir
. ./go-build.sh
cd "$1"; shift 2

show_help_b83799b() {
  cat <<EOF
Build Go executable package with debugger option and run in debug mode.

Usage: $0 <package> [<cmd_arg>...]
       $0 [<build_opt>...] <package> -- [<cmd_arg>...]
EOF
}

go_run() {
  test "$#" -lt 1 && show_help_b83799b && return 1
  local a_out="$TEMP_DIR/a.out$exe_ext"
  local arg
  local separated=false
  local first=true
  for arg in "$@" --
  do
    "$first" && set -- && first=false
    if test "$arg" = --
    then
      "$separated" && break
      separated=true
      go_build -tags=debug -o "$a_out" "$@"
      set --
      continue
    fi
    set -- "$@" "$arg"
  done
  set -- "$a_out" "$@"
  echo Executing: "$@" >&2
  "$@"
}

case "${0##*/}" in
  (go-run.sh|go-run)
    set -o nounset -o errexit
    go_run "$@"
    ;;
esac
