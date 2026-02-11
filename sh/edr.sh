#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3ddfb53-false}" && return 0; sourced_3ddfb53=true

# Edit in raw mode.

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
shift 2
. ./edw.sh
cd "$1" || exit 1; shift 2

check() {
  local origin="$1"
  local file="$2"
  if newer "$file" --than "$origin"
  then
    cat "$file" >"$origin"
  fi
}

edr() {
  register_temp_cleanup
  test $# -ge 1 || return
  local origin="$1"
  local file
  file="$(mktemp "$TEMP_DIR"/edr_XXXXXX)"
  cp -a "$origin" "$file"
  while true
  do
    check "$origin" "$file"
    sleep 5
  done &
  defer_child_cleanup
  edw "$file"
  check "$origin" "$file"
}

case "${0##*/}" in
  (edr.sh|edr)
    set -o nounset -o errexit
    edr "$@"
    ;;
esac
