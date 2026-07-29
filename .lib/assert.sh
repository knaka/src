#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_ASSERT_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

# Assertion functions

assert_eq() {
  local message="${3:-}"
  OPTIND=1; while getopts _-:m: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (m|message) message="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  test "$1" = "$2" 2>/dev/null && return 0
  test "$1" -eq "$2" 2>/dev/null && return 0
  printf "Equality assertion failed%s\n" "${message:+ ($message)}"
  print_call_stack
  printf "  LHS: %s\n" "$1"
  printf "  RHS: %s\n" "$2"
  return 1
}

assert_neq() {
  local message="${3:-}"
  OPTIND=1; while getopts _-:m: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (m|message) message="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  test "$1" = "$2" || return 0
  printf "Inequality assertion failed%s\n" "${message:+ ($message)}"
  print_call_stack
  printf "  LHS: %s\n" "$1"
  printf "  RHS: %s\n" "$2"
  return 1
}

assert() {
  local message=
  OPTIND=1; while getopts _-:m: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (m|message) message="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  "$@" && return 0
  printf "Failed: \"%s\" is not true%s\n" "$*" "${message:+ ($message)}"
  print_call_stack
  return 1
}

assert_true() {
  local message=
  OPTIND=1; while getopts _-:m: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (m|message) message="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  "$@" && return 0
  printf "Failed: \"%s\" is not true%s\n" "$*" "${message:+ ($message)}"
  print_call_stack
  return 1
}

assert_success() {
  assert_true "$@"
}

assert_failure() {
  local message=
  OPTIND=1; while getopts _-:m: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (m|message) message="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  "$@" || return 0
  printf "Failed: \"%s\" is not false%s\n" "$*" "${message:+ ($message)}"
  print_call_stack
  return 1
}

assert_false() {
  assert_failure "$@"
}

# assert_match <expected> <actual>
assert_match() {
  local message="${3:-}"
  OPTIND=1; while getopts _-:m: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (m|message) message="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  echo "$2" | grep -E -q "$1" && return 0
  printf "Failed: \"%s\" does not match \"%s\"%s\n" "$2" "$1" "${message:+ ($message)}"
  print_call_stack
  return 1
}

# Unconditionally fail, e.g. for code paths that should never be reached.
assert_fail() {
  local message=
  OPTIND=1; while getopts _-:m: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (m|message) message="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  printf "Failed%s\n" "${message:+ ($message)}"
  print_call_stack
  return 1
}
