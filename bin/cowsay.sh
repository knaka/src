#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_fcad6c8-false}" && return 0; sourced_fcad6c8=true

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift

# cowsay - npm https://www.npmjs.com/package/cowsay
cowsay_version_14ac6ce=1.6.0

set_cowsay_version() {
  cowsay_version_14ac6ce="$1"
}

cowsay() {
  mise_exec "npm:cowsay@$cowsay_version_14ac6ce" -- cowsay "$@"
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }
if _ cowsay
then
  set -o nounset -o errexit
  cowsay "$@"
fi
