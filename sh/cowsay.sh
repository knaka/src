#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_fcad6c8-false}" && return 0; sourced_fcad6c8=true

# cowsay - npm https://www.npmjs.com/package/cowsay
cowsay_version_14ac6ce=1.6.0

set_cowsay_version() {
  cowsay_version_14ac6ce="$1"
}

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
shift 2
cd "$1" || exit 1; shift 2

cowsay() {
  mise exec npm:"cowsay@$cowsay_version_14ac6ce" -- cowsay "$@"
}

case "${0##*/}" in
  (cowsay.sh|cowsay)
    set -o nounset -o errexit
    cowsay "$@"
    ;;
esac
