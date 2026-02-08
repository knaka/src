#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_997bcd2-false}" && return 0; sourced_997bcd2=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi; set -- _LIBDIR ./sub/ "$@"
. ./sub/sub.lib.sh
shift 2; cd "$1" || exit 1; shift

x868cb14() {
  echo f209986 main lib
}
