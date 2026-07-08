#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8cac2e4-false}" && return 0; sourced_8cac2e4=true

# Display the date and time in ISO 8601 format.

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift
cd "$1" || exit 1; shift 2

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

_() {
  local x="$1"
  shift
  x="${x##*/}"
  x="${x##*\\}"
  IFS=,
  case ",$*," in
    (*,"${x%.sh}",*)
      return 0
      ;;
  esac
  return 1
}

if _ "$0" date-rfc3339 date-iso
then
  set -o nounset -o errexit
  date_iso "$@"
fi
