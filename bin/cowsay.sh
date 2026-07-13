#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 3601669 && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1:+$1}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
. ./.lib/commands.sh
shift 2
cd "$1" || exit; shift

# cowsay - npm https://www.npmjs.com/package/cowsay
cowsay_version_14ac6ce=1.6.0

set_cowsay_version() {
  cowsay_version_14ac6ce="$1"
}

cowsay() {
  mise exec "npm:cowsay@$cowsay_version_14ac6ce" -- cowsay "$@"
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ cowsay
then
  set -o nounset -o errexit
  cowsay "$@"
fi
