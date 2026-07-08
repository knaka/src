#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 217fa39 && return 0

# test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
# if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
# set -- _LIBDIR ./.lib "$@"
# . ./.lib/utils.sh
# shift 2
# cd "$1" || exit 1; shift

dec_to_bin() {
  local dec
  for dec in "$@"
  do
    local bin=
    while test "$dec" -gt 0
    do
      bin=$((dec % 2))$bin
      dec=$((dec / 2))
    done
    echo "${bin:-0}"
  done
}

hex_to_dec() {
  local hex
  for hex in "$@"
  do
    hex="${hex#0x}"
    hex="0x$hex"
    printf "%d\n" "$hex"
  done
}

dec_to_hex() {
  printf "0x%X\n" "$@"
}

bin_to_dec() {
  local bin
  for bin in "$@"
  do
    local dec=0
    while :
    do
      if test -z "$bin"
      then
        printf "%d\n" "$dec"
        continue 2
      fi
      local digit
      digit="${bin%"${bin#?}"}"
      bin="${bin#?}"
      dec=$((dec * 2 + digit))  
    done
  done
}

radix() {
  echo "Function \"radix\" is not implemented yet."
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ radix
then
  set -o nounset -o errexit
  radix "$@"
fi
