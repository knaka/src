#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 23c098a && return 0

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift 2

beep() {
  if is_windows
  then
    # pwsh -c "[console]::beep(1000,300)" &
    rundll32 user32.dll,MessageBeep &
  elif is_macos
  then
    osascript -e 'beep' &
  else
    # Emit a terminal bell (BEL) character to trigger an audible or visual alert.
    printf '\a'
  fi
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ beep
then
  set -o nounset -o errexit
  beep "$@"
fi
