#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ _LIB_RADIX_SH && return # shpp:source_guard

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
