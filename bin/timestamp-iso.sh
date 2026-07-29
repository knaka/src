#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_TIMESTAMP_ISO_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

iso_date_format='%Y-%m-%dT%H:%M:%S%z'

# Print file timestamp in ISO format.
timestamp_iso() {
  if is_bsd
  then
    # S: String
    # a, m, c, B: Last accessed or modified, or when the inode was last changed, or the birth time of the inode
    stat -f "%Sm" -t "$iso_date_format" "$1"
  elif is_windows
  then
    local epoch
    epoch="$(stat -c "%Y" "$1")"
    date -d @"$epoch" -Iseconds
    return
  else
    date --date "$(stat --format "%y" "$1")" +"$iso_date_format"
  fi
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.timestamp-iso.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  timestamp_iso "$@"
fi
