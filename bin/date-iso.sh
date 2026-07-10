#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8cac2e4-false}" && return 0; sourced_8cac2e4=true

# Display the date and time in ISO 8601 format.

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift

# https://ijmacd.github.io/rfc3339-iso8601/

iso_date_format='%Y-%m-%dT%H:%M:%S%z'

date_iso() {
  if is_bbwin
  then
    if which jq >/dev/null 2>&1
    then
      jq -nr 'now | strftime("%FT%T%z")'
      return $?
    fi
    # -I[SPEC]: Output ISO-8601 date / SPEC=date (default), hours, minutes, seconds or ns
    date -Iseconds
    return $?
  fi
  if is_macos
  then
    # -j: Do not try to set the date
    date -j +"$iso_date_format"
    return $?
  fi
  date +"$iso_date_format"
}

if cmdbase_snake_ "$0"; test "$RESULT" = date_iso
then
  set -o nounset -o errexit
  date_iso "$@"
fi
