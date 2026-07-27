#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_92d8973-false}" && return 0; sourced_92d8973=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/time.sh
cd "$3" || exit; shift 3

case "${0##*/}" in
  (touch-time-iso.sh|touch-time-iso)
    set -o nounset -o errexit
    touch_time_iso "$@"
    ;;
esac
