#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_66b0bec-false}" && return 0; sourced_66b0bec=true

# Launch editor and block until it exits.

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@"
. ./ed.sh
cd "$3" || exit; shift 3

edw() {
  ed --wait "$@"
}

case "${0##*/}" in
  (edw.sh|edw)
    set -o nounset -o errexit
    edw "$@"
    ;;
esac
