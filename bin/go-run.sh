#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_GO_RUN_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
  init_temp_dir
shift 2; set -- _SCRDIR . "$@" # shpp:sources_chdir
. ./go-build.sh
cd "$3" || exit; shift 3 # /shpp:sources

show_help_b83799b() {
  cat <<EOF
Build Go executable package with debugger option and run in debug mode.

Usage: $0 <package> [<cmd_arg>...]
       $0 [<build_opt>...] <package> -- [<cmd_arg>...]
EOF
}

go_run() {
  test "$#" -lt 1 && show_help_b83799b && return 1
  local a_out="$TEMP_DIR/a.out$EXE_EXT"
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

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (go-run.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  go_run "$@"
fi
