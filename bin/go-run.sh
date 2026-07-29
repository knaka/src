#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_GO_RUN_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
  init_temp_dir
shift 2; set -- SCRIPTDIR . "$@" # shpp:else
. ./go-build.sh
cd "$3" || exit; shift 3 # shpp:end_source

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.go-run.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  go_run "$@"
fi
