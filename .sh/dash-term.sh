#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 8fe79db && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift

dash_term() {
  register_child_cleanup
  while :
  do
    echo world
    sleep 1
  done &
  sleep 5
  echo hello
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ dash_term || _ dash-term
then
  echo cf20291
  set -o nounset -o errexit
  dash_term "$@"
fi
