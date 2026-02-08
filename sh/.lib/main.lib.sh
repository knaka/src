#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_997bcd2-false}" && return 0; sourced_997bcd2=true

echo hoge >&2
pwd >&2

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" || exit 1; fi
set -- _LIBDIR .
pwd
shift 2
cd "$1" || exit 1; shift 2

pwd  >&2
echo fuga >&2

x868cb14() {
  echo f209986 main lib
}
