#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_92d8973-false}" && return 0; sourced_92d8973=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./task.sh
cd "$1" || exit 1; shift 2

iso_time_format='%Y-%m-%dT%H:%M:%S%z'
iso_time_format_utc='%Y-%m-%dT%H:%M:%SZ'

# Touch files with specified ISO-8601 time.
# Usage: touch_time_iso <ISO_time> <file>...
# Example: touch_time_iso 2024-01-01T12:00:00Z file1.txt file2.txt
touch_time_iso() {
  local time="$1"
  shift
  if is_windows
  then
    # BusyBox date(1) does not seem to handle "%z". Use PowerShell to do this.
    pwsh.exe -NoProfile -Command "Set-ItemProperty \"$1\" -Name LastWriteTime -Value \"$time\""
    return
  fi
  if is_bsd
  then
    # BSD touch(1) does not accept ISO time with timezone. Convert to UTC.
    time="$(TZ=UTC date -j -f "$iso_time_format" "$time" +"$iso_time_format_utc")"
  fi
  touch -d "$time" "$@"
}

case "${0##*/}" in
  (touch-time-iso.sh|touch-time-iso)
    set -o nounset -o errexit
    touch_time_iso "$@"
    ;;
esac
