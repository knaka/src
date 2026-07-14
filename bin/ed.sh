#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_ED_SH && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
shift 2
cd "$1" || exit; shift

ed() {
  cd "$_APPDIR" || return 1
  ./mise exec -- python ./_chdir.py "$OLDPWD" "$_APPDIR"/ed.py "$@"
  cd "$OLDPWD" || return 1
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ ed
then
  set -o nounset -o errexit
  ed "$@"
fi
