#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ c3a6820 && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
. ./sc.sh
. ./gc.sh
shift 2
cd "$1" || exit 1; shift

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
