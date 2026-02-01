#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3ae0529-false}" && return 0; sourced_3ae0529=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
  init_temp_dir
. ./ed.sh
cd "$1"; shift 2

vw() {
  local title="(stdin)"
  if test $# -ge 1
  then
    title="$(basename "$1") (RO)"
  fi
  local file_path="$TEMP_DIR"/"$title"
  cat "$@" >"$file_path"
  chmod 444 "$file_path"
  ed --block "$file_path"
}

case "${0##*/}" in
  (vw.sh|vw)
    set -o nounset -o errexit
    vw "$@"
    ;;
esac
