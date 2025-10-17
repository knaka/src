#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ddce48a-false}" && return 0; sourced_ddce48a=true

args_sort() {
  local ifs_saved="$IFS"
  # Unit Separator
  local us=""
  IFS="$us"
  # shellcheck disable=SC2046
  set -- $(printf "%s${us}" "$@" | sort --field-separator "$us")
  IFS="$ifs_saved"
  printf "%s\n" "$@"
}

args_sort 789 123 "cdef${us}gabc" xyz "_ _" abc
