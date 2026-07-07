#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_163e1a5-false}" && return 0; sourced_163e1a5=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

sh_ifsv_loop() {
  local usv=
  usv="${usv}foo bar$ch_us"
  usv="${usv}  bar  baz$ch_us"
  usv="${usv}   qux   qux$ch_us"

  local item
  local IFS="$ch_us"
  for item in $usv
  do
    echo "item: $item"
  done
}

set -o nounset -o errexit
sh_ifsv_loop "$@"
