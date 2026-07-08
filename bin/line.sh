#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 3332186 && return 0

line() {
  local char="-"
  local count=76
  if test $# -eq 1
  then
    count=$1
  elif test $# -gt 1
  then
    char=$1
    count=$2
    case "$char" in
      ([0-9]|[0-9][0-9]|[0-9][0-9][0-9])
        if test "${#count}" -eq 1
        then
          local temp="$char"
          char="$count"
          count="$temp"
        fi
    esac
  fi
  printf "%${count}s\n" "" | tr ' ' "$char"
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ line
then
  set -o nounset -o errexit
  line "$@"
fi
