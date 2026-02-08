#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b361d7d-false}" && return 0; sourced_b361d7d=true

# ClipBoard ARchiver

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./sc.sh
. ./gc.sh
cd "$1" || exit 1; shift 2

cbar() {
  if test $# -ge 1
  then
    # If arguments are specified, archive them as files/directories, convert to text, and set to clipboard.
    tar czvf - "$@" | base64 | sc
  else
    # If no arguments are specified, extract the clipboard content as an archive.
    gc | base64 -d | tar zxvf -
  fi
}

case "${0##*/}" in
  (cbar.sh|cbar)
    set -o nounset -o errexit
    cbar "$@"
    ;;
esac
