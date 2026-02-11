#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e2499a6-false}" && return 0; sourced_e2499a6=true

# set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
# set -- _LIBDIR . "$@"
# shift 2
# cd "$1" || exit 1; shift 2

show_path() {
  local IFS=:
  # shellcheck disable=SC2086
  printf "%s\n" $PATH
}

case "${0##*/}" in
  (show-path.sh|show-path)
    set -o nounset -o errexit
    show_path "$@"
    ;;
esac
