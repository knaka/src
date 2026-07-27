#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_bd334b5-false}" && return 0; sourced_bd334b5=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
cd "$3" || exit; shift 3

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

case "${0##*/}" in
  (timestamp-iso.sh|timestamp-iso)
    set -o nounset -o errexit
    timestamp_iso "$@"
    ;;
esac
