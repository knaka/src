#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ c3a6820 && return 0

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR . "$@"
. ./sc.sh
. ./gc.sh
shift 2
cd "$1" || exit 1; shift 2

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
