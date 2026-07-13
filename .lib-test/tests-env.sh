#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ c6857eb && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; }
case "${1:+$1}" in (_LIBDIR) cd "$2" || exit 1;; (*) cd "$_APPDIR" || exit 1;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift

test_env() {
  if is_bash_bin
  then
    bash --version
  elif is_bbwin
  then
    busybox --help
  elif test -r /proc/$$/exe
  then
    echo "/proc/$$/exe"
    readlink /proc/$$/exe | xargs basename
  elif is_macos
  then
    ps -p $$ -o args=
  else
    echo Invalid env. >&2
  fi
}
