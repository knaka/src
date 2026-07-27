#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_d53a347-false}" && return 0; sourced_d53a347=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/commands.sh
cd "$3" || exit; shift 3

t2m() {
  mlr --pass-comments --t2m cat "$@"
}

case "${0##*/}" in
  (t2m.sh|t2m)
    set -o nounset -o errexit
    t2m "$@"
    ;;
esac
