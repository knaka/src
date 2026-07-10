#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 0735e71 && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift

: "${my_temp-}"

clean_my_temp() {
  rm -fr "$my_temp"
  echo Cleaned "$my_temp"
  ls -l "$my_temp" || :
  unset my_temp
  trap
}

trap_it() {
  my_temp="$(mktemp -d)"
  ls -l "$my_temp"
  trap clean_my_temp EXIT
  echo Parent
  trap
  local old
  old=$( (trap) )
  echo 0e8faac "$old"
  echo ----
  (
    echo Child
    trap
    echo ----
  )
  sleep 3
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ trap
then
  set -o nounset -o errexit
  trap_it "$@"
fi
