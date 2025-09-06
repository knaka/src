#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b8dd816-false}" && return 0; sourced_b8dd816=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
  init_temp_dir
. ./go-build.sh
cd "$1"; shift 2

go_run() {
  local exe="$TEMP_DIR/go_run_out$exe_ext"
  go_build -o "$exe" "$@"
  local count=1
  for arg in "$@"
  do
    test "$arg" = -- && break
    count=$((count + 1))
  done
  if test "$count" -ge "$#"
  then
    count=1
  fi
  shift "$count"
  WAIT_DEBUGGER=true "$exe" "$@"
}

case "${0##*/}" in
  (go-run.sh|go-run)
    set -o nounset -o errexit
    go_run "$@"
    ;;
esac
