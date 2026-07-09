#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 6021217 && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit 1; shift

# ==========================================================================
#region Map (associative array) functions. "IFS-Separated Map"

# Put a value in an associative array implemented as a property list.
ifsm_put() {
  local key="$2"
  local value="$3"
  # shellcheck disable=SC2086
  set -- $1
  # First char of IFS
  local delim="${IFS%"${IFS#?}"}"
  while test $# -gt 0
  do
    test "$1" != "$key" && printf "%s%s%s%s" "$1" "$delim" "$2" "$delim"
    shift 2
  done
  printf "%s%s%s%s" "$key" "$delim" "$value" "$delim"
}

# Get a value from an associative array implemented as a property list.
ifsm_get() {
  local key="$2"
  # shellcheck disable=SC2086
  set -- $1
  while test $# -gt 0
  do
    test "$1" = "$key" && printf "%s" "$2" && return 0
    shift 2
  done
  return 1
}

# Keys of an associative array implemented as a property list.
ifsm_keys() {
  # shellcheck disable=SC2086
  set -- $1
  # First char of IFS
  local delim="${IFS%"${IFS#?}"}"
  while test $# -gt 0
  do
    printf "%s%s" "$1" "$delim"
    shift 2
  done
}

# Values of an associative array implemented as a property list.
ifsm_values() {
  # shellcheck disable=SC2086
  set -- $1
  # First char of IFS
  local delim="${IFS%"${IFS#?}"}"
  while test $# -gt 0
  do
    printf "%s%s" "$2" "$delim"
    shift 2
  done
}

#endregion
