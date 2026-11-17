#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_STRING_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

# ==========================================================================
#region String functions not using subshell.

# Each function below prints its result, or assigns it to the variable given with "-v var" as printf of Bash does, so that the caller does not need a command substitution, which forks a subshell. Positions are counted from 1, as in AWK.
# A function with any logic consists of an inner function with a hash-suffixed name, which sets the result to result_db1c0eb and is free to use any local variables, and an outer function, which has no local variables other than hash-suffixed ones, so that they do not shadow the variable whose name is given by the caller.

result_db1c0eb=

toupper_51d18b8() {
  # shellcheck disable=SC3059
  is_bash_bin 4 && result_db1c0eb="${*^^}" && return
  local result=
  local s="$*"
  local c
  while test -n "$s"
  do
    c="${s%"${s#?}"}"
    s="${s#?}"
    case "$c" in
      (a) result="${result}A";;
      (b) result="${result}B";;
      (c) result="${result}C";;
      (d) result="${result}D";;
      (e) result="${result}E";;
      (f) result="${result}F";;
      (g) result="${result}G";;
      (h) result="${result}H";;
      (i) result="${result}I";;
      (j) result="${result}J";;
      (k) result="${result}K";;
      (l) result="${result}L";;
      (m) result="${result}M";;
      (n) result="${result}N";;
      (o) result="${result}O";;
      (p) result="${result}P";;
      (q) result="${result}Q";;
      (r) result="${result}R";;
      (s) result="${result}S";;
      (t) result="${result}T";;
      (u) result="${result}U";;
      (v) result="${result}V";;
      (w) result="${result}W";;
      (x) result="${result}X";;
      (y) result="${result}Y";;
      (z) result="${result}Z";;
      (*) result="${result}$c";;
    esac
  done
  result_db1c0eb="$result"
}

# Convert the lowercase letters of the arguments, joined with spaces, to uppercase. Without Bash 4 or later, only the ASCII letters are converted.
# Usage: toupper [-v var] string...
toupper() {
  local var_name_d73bbfe=
  test "${1-}" = "-v" && var_name_d73bbfe="$2" && shift 2
  toupper_51d18b8 "$@"
  print_to "$var_name_d73bbfe" "$result_db1c0eb"
}

tolower_f07fef8() {
  # shellcheck disable=SC3059
  is_bash_bin 4 && result_db1c0eb="${*,,}" && return
  local result=
  local s="$*"
  local c
  while test -n "$s"
  do
    c="${s%"${s#?}"}"
    s="${s#?}"
    case "$c" in
      (A) result="${result}a";;
      (B) result="${result}b";;
      (C) result="${result}c";;
      (D) result="${result}d";;
      (E) result="${result}e";;
      (F) result="${result}f";;
      (G) result="${result}g";;
      (H) result="${result}h";;
      (I) result="${result}i";;
      (J) result="${result}j";;
      (K) result="${result}k";;
      (L) result="${result}l";;
      (M) result="${result}m";;
      (N) result="${result}n";;
      (O) result="${result}o";;
      (P) result="${result}p";;
      (Q) result="${result}q";;
      (R) result="${result}r";;
      (S) result="${result}s";;
      (T) result="${result}t";;
      (U) result="${result}u";;
      (V) result="${result}v";;
      (W) result="${result}w";;
      (X) result="${result}x";;
      (Y) result="${result}y";;
      (Z) result="${result}z";;
      (*) result="${result}$c";;
    esac
  done
  result_db1c0eb="$result"
}

# Convert the uppercase letters of the arguments, joined with spaces, to lowercase. Without Bash 4 or later, only the ASCII letters are converted.
# Usage: tolower [-v var] string...
tolower() {
  local var_name_38a9271=
  test "${1-}" = "-v" && var_name_38a9271="$2" && shift 2
  tolower_f07fef8 "$@"
  print_to "$var_name_38a9271" "$result_db1c0eb"
}

substr_6896cc4() {
  local result=
  local s="$1"
  local start="$2"
  local length="${3-${#s}}"
  # shellcheck disable=SC3057
  is_bash_bin && result_db1c0eb="${s:$((start-1)):$length}" && return
  local end=$((start+length))
  local c
  local i=1
  while test -n "$s"
  do
    c="${s%"${s#?}"}"
    s="${s#?}"
    if test "$i" -ge "$start" -a "$i" -lt "$end"
    then
      result="${result}$c"
    fi
    i=$((i+1))
  done
  result_db1c0eb="$result"
}

# Extract the substring of the given length that starts at the given position. Without the length, the substring extends to the end of the string.
# Usage: substr [-v var] string start [length]
substr() {
  local var_name_63e088f=
  test "${1-}" = "-v" && var_name_63e088f="$2" && shift 2
  substr_6896cc4 "$@"
  print_to "$var_name_63e088f" "$result_db1c0eb"
}

strsub_4f61a36() {
  local s="$1"
  local from="$2"
  test -z "$from" && result_db1c0eb="$s" && return
  local to="$3"
  # Quote the search string so that it is matched literally, not as a pattern. Quote the replacement so that "&" is not replaced with the matched string on Bash 5.2 or later, where patsub_replacement is on by default. Bash before 4.3 does not remove the quotes from the replacement, so leave it unquoted there, where "&" has no special meaning anyway.
  # shellcheck disable=SC3060
  is_bash_bin 5 && result_db1c0eb="${s/"$from"/"$to"}" && return
  # shellcheck disable=SC3060
  is_bash_bin && result_db1c0eb="${s/"$from"/$to}" && return
  local left="${s%%"$from"*}"
  test "$left" = "$s" && result_db1c0eb="$s" && return
  result_db1c0eb="$left$to${s#*"$from"}"
}

# Replace the first occurrence of the search string with the replacement. The string is left unchanged if the search string is empty or not found.
# Usage: strsub [-v var] string search replacement
strsub() {
  local var_name_500b259=
  test "${1-}" = "-v" && var_name_500b259="$2" && shift 2
  strsub_4f61a36 "$@"
  print_to "$var_name_500b259" "$result_db1c0eb"
}

strgsub_93d9cfe() {
  local result=
  local s="$1"
  local from="$2"
  test -z "$from" && result_db1c0eb="$s" && return
  local to="$3"
  # Quote the search string and the replacement for the same reason as in strsub_4f61a36.
  # shellcheck disable=SC3060
  is_bash_bin 5 && result_db1c0eb="${s//"$from"/"$to"}" && return
  # shellcheck disable=SC3060
  is_bash_bin && result_db1c0eb="${s//"$from"/$to}" && return
  while test -n "$s"
  do
    local left="${s%%"$from"*}"
    test "$left" = "$s" && result="$result$s" && break
    result="$result$left$to"
    s="${s#*"$from"}"
  done
  result_db1c0eb="$result"
}

# Replace every occurrence of the search string with the replacement. The string is left unchanged if the search string is empty or not found.
# Usage: strgsub [-v var] string search replacement
strgsub() {
  local var_name_d99288a=
  test "${1-}" = "-v" && var_name_d99288a="$2" && shift 2
  strgsub_93d9cfe "$@"
  print_to "$var_name_d99288a" "$result_db1c0eb"
}

strpos_c5d592a() {
  local s="$1"
  local find="$2"
  test -z "$find" && result_db1c0eb=0 && return
  local left="${s%%"$find"*}"
  test "$left" = "$s" && result_db1c0eb=0 && return
  result_db1c0eb=$((${#left}+1))
}

# Get the position of the first occurrence of the search string, or 0 if the search string is empty or not found.
# Usage: strpos [-v var] string search
strpos() {
  local var_name_42f956e=
  test "${1-}" = "-v" && var_name_42f956e="$2" && shift 2
  strpos_c5d592a "$@"
  print_to "$var_name_42f956e" "$result_db1c0eb"
}

# Get the number of characters in the string.
# Usage: strlen [-v var] string
strlen() {
  local var_name_e584d71=
  test "${1-}" = "-v" && var_name_e584d71="$2" && shift 2
  print_to "$var_name_e584d71" "${#1}"
}

# Replace every occurrence of the separator with the delimiter, a space by default, so that the fields can be split by setting IFS to the delimiter.
# Usage: strsplit [-v var] [--delim=delimiter] string separator
strsplit() {
  local var_name_4a3f3b4=
  local delim_aa102b9=" "
  OPTIND=1; while getopts v:-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (v) var_name_4a3f3b4="$OPTARG";;
      (delim|delimiter|result-delim|result-delimiter) delim_aa102b9="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))
  strgsub_93d9cfe "$1" "$2" "$delim_aa102b9"
  print_to "$var_name_4a3f3b4" "$result_db1c0eb"
}

# Test the functions above. Run when this file is executed directly.
test_lib_string_sh() {
  if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
  . ./assert.sh
  cd "$3" || exit; shift 3 # /shpp:sources

  local result
  toupper -v result "aBc"
  assert_eq "$result" "ABC"
  assert_eq "$(toupper "aBc")" "ABC"
  tolower -v result "AbC"
  assert_eq "$result" "abc"
  substr -v result "123456789" 4 3
  assert_eq "$result" "456"
  strsub -v result "foo bar baz bar" "bar" "xyz"
  assert_eq "$result" "foo xyz baz bar"
  strgsub -v result "foo bar baz bar 123" "bar" "xyz"
  assert_eq "$result" "foo xyz baz xyz 123"
  # The search string and the replacement are taken literally.
  strsub -v result "a*b?c a*b?c" "*b?" "[&]"
  assert_eq "$result" "a[&]c a*b?c"
  strgsub -v result "a*b?c a*b?c" "*b?" "[&]"
  assert_eq "$result" "a[&]c a[&]c"
  strpos -v result "peanut" "an"
  assert_eq "$result" 3
  strlen -v result "apple"
  assert_eq "$result" 5
  strsplit -v result "cul-de-sac" "-"
  assert_eq "$result" "cul de sac"

  echo OK. >&2
}

#endregion 

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (string.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  test_lib_string_sh "$@"
fi
