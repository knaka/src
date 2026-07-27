#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7f5d0a8-false}" && return 0; sourced_7f5d0a8=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/commands.sh
cd "$3" || exit; shift 3

m2c() {
  mlr --pass-comments --m2c cat "$@"
}

case "${0##*/}" in
  (m2c.sh|m2c)
    set -o nounset -o errexit
    m2c "$@"
    ;;
esac
