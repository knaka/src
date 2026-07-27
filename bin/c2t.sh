#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7f3a869-false}" && return 0; sourced_7f3a869=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/commands.sh
cd "$3" || exit; shift 3

c2t() {
  mlr --pass-comments --c2t cat "$@"
}

case "${0##*/}" in
  (c2t.sh|c2t)
    set -o nounset -o errexit
    c2t "$@"
    ;;
esac
