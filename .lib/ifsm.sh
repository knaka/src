#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ _LIB_IFSM_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@" # shpp:begin_source
. ./utils.sh
cd "$3" || exit; shift 3 # shpp:end_source

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
