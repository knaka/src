#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3ae0529-false}" && return 0; sourced_3ae0529=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./utils.lib.sh
. ./ed.sh
cd "$1" || exit 1; shift 2

vw() {
  register_temp_cleanup
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
