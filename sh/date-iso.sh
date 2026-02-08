#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8cac2e4-false}" && return 0; sourced_8cac2e4=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./utils.libsh
cd "$1" || exit 1; shift 2

# https://ijmacd.github.io/rfc3339-iso8601/

iso_date_format='%Y-%m-%dT%H:%M:%S%z'

date_iso() {
  if is_windows
  then
    # -I[SPEC]: Output ISO-8601 date / SPEC=date (default), hours, minutes, seconds or ns
    date -Iseconds
    return
  fi
  # -j: Do not try to set the date
  date -j +"$iso_date_format"
}

case "${0##*/}" in
  (date-iso|date-iso.sh|date-rfc3339|date-rfc3339.sh)
    set -o nounset -o errexit
    date_iso "$@"
    ;;
esac
