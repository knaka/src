#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_LINE_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

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

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (line.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  line "$@"
fi
