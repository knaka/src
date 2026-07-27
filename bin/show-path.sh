#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e2499a6-false}" && return 0; sourced_e2499a6=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
cd "$3" || exit; shift 3

show_path() {
  # if is_windows
  # then
  #   echo 'Not for Windows. Call "win-env" instead.' >&2
  #   exit 1
  # fi
  local IFS=':'
  # shellcheck disable=SC2086
  printf "%s\n" $PATH
}

case "${0##*/}" in
  (show-path.sh|show-path)
    set -o nounset -o errexit
    show_path "$@"
    ;;
esac
