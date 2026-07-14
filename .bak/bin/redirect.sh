#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ f64120a && return 0

# test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
# case "${1:+$1}" in (_LIBDIR) cd "$2" || exit 1;; (*) cd "$_APPDIR" || exit 1;; esac; set -- "$OLDPWD" "$@";
# set -- _LIBDIR ../.lib "$@"
# . ../.lib/utils.sh
# shift 2
# cd "$1" || exit 1; shift

redirect() {
  exec 9>&1
  echo hello1 >&1
  exec 1> /tmp/hello.txt
  echo hello2 >&1
  exec 1>&9 9>&-
  echo hello3 >&1
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) :;; (*) ! :;; esac; }; if _ redirect
then
  set -o nounset -o errexit
  redirect "$@"
fi
