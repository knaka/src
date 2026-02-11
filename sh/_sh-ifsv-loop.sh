#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_163e1a5-false}" && return 0; sourced_163e1a5=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./utils.lib.sh
cd "$1"; shift 2

sh_ifsv_loop() {
  local usv=
  usv="${usv}foo$us"
  usv="${usv}bar$us"
  usv="${usv}baz$us"

  local item
  local saved_ifs="$IFS"; IFS="$us"
  for item in $usv
  do
    echo "item: $item"
  done
  IFS="$saved_ifs"
}

case "${0##*/}" in
  (sh-ifsv-loop.sh|sh-ifsv-loop)
    set -o nounset -o errexit
    sh_ifsv_loop "$@"
    ;;
esac
