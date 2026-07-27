#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ c3a6820 && return 0

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ./sc.sh
. ./gc.sh
cd "$3" || exit; shift 3

# ClipBoard ARchiver
cbar() {
  if test $# -gt 0
  then
    # If arguments are specified, archive them as files/directories, convert to text, and set to clipboard.
    tar czvf - "$@" | base64 | sc
  else
    # If no arguments are specified, extract the clipboard content as an archive.
    gc | base64 -d | tar zxvf -
  fi
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ cbar
then
  set -o nounset -o errexit
  cbar "$@"
fi
