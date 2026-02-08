#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_363fa5f-false}" && return 0; sourced_363fa5f=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" || exit 1; fi; set -- _LIBDIR ./.lib
. ./.lib/main.lib.sh
shift 2; shift

_sh_relative() {
  x868cb14
  x15e92d1
}

case "${0##*/}" in
  (_sh-relative.sh|_sh-relative)
    set -o nounset -o errexit
    _sh_relative "$@"
    ;;
esac
