#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_STRING_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

# ==========================================================================
#region AWK-like string functions not using subshell.

# Each function below sets its result to $RESULT instead of printing it, so that the caller does not need a command substitution, which forks a subshell. Positions are counted from 1, as in AWK.

# Convert the lowercase letters of the arguments, joined with spaces, to uppercase. Without Bash 4 or later, only the ASCII letters are converted.
# Usage: toupper_ string...
toupper_() {
  # shellcheck disable=SC3059
  is_bash_bin 4 && set_ "${*^^}" && return
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
  set_ "$result"
}

# Convert the uppercase letters of the arguments, joined with spaces, to lowercase. Without Bash 4 or later, only the ASCII letters are converted.
# Usage: tolower_ string...
tolower_() {
  # shellcheck disable=SC3059
  is_bash_bin 4 && set_ "${*,,}" && return
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
  set_ "$result"
}

# Extract the substring of the given length that starts at the given position. Without the length, the substring extends to the end of the string.
# Usage: substr_ string start [length]
substr_() {
  local result=
  local s="$1"
  local start="$2"
  local length="${3-${#s}}"
  # shellcheck disable=SC3057
  is_bash_bin && set_ "${s:$((start-1)):$length}" && return
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
  set_ "$result"
}

# Replace the first occurrence of the search string with the replacement. The string is left unchanged if the search string is empty or not found.
# Usage: sub_ string search replacement
sub_() {
  local s="$1"
  local from="$2"
  test -z "$from" && set_ "$s" && return
  local to="$3"
  # Quote the search string so that it is matched literally, not as a pattern. Quote the replacement so that "&" is not replaced with the matched string on Bash 5.2 or later, where patsub_replacement is on by default. Bash before 4.3 does not remove the quotes from the replacement, so leave it unquoted there, where "&" has no special meaning anyway.
  # shellcheck disable=SC3060
  is_bash_bin 5 && set_ "${s/"$from"/"$to"}" && return
  # shellcheck disable=SC3060
  is_bash_bin && set_ "${s/"$from"/$to}" && return
  local left="${s%%"$from"*}"
  test "$left" = "$s" && set_ "$s" && return
  set_ "$left$to${s#*"$from"}"
}

# Replace every occurrence of the search string with the replacement. The string is left unchanged if the search string is empty or not found.
# Usage: gsub_ string search replacement
gsub_() {
  local result=
  local s="$1"
  local from="$2"
  test -z "$from" && set_ "$s" && return
  local to="$3"
  # Quote the search string and the replacement for the same reason as in sub_.
  # shellcheck disable=SC3060
  is_bash_bin 5 && set_ "${s//"$from"/"$to"}" && return
  # shellcheck disable=SC3060
  is_bash_bin && set_ "${s//"$from"/$to}" && return
  while test -n "$s"
  do
    local left="${s%%"$from"*}"
    test "$left" = "$s" && result="$result$s" && break
    result="$result$left$to"
    s="${s#*"$from"}"
  done
  set_ "$result"
}

# Get the position of the first occurrence of the search string, or 0 if the search string is empty or not found.
# Usage: index_ string search
index_() {
  local s="$1"
  local find="$2"
  test -z "$find" && set_ 0 && return
  local left="${s%%"$find"*}"
  test "$left" = "$s" && set_ 0 && return
  set_ $((${#left}+1))
}

# Get the number of characters in the string.
# Usage: length_ string
length_() {
  set_ ${#1}
}

# Replace every occurrence of the separator with the delimiter, a space by default, so that the fields can be split by setting IFS to the delimiter.
# Usage: split_ [--delim=delimiter] string separator
split_() {
  local delim=" "
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (delim|delimiter|result-delim|result-delimiter) delim="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  gsub_ "$1" "$2" "$delim"
}

# Test the functions above. Run when this file is executed directly.
# shellcheck disable=SC2153
test_lib_string_sh() {
  set -- _SCRDIR .
  . ./assert.sh
  shift 2

  toupper_ "aBc"
  assert_eq "$RESULT" "ABC"
  tolower_ "AbC"
  assert_eq "$RESULT" "abc"
  substr_ "123456789" 4 3
  assert_eq "$RESULT" "456"
  sub_ "foo bar baz bar" "bar" "xyz"
  assert_eq "$RESULT" "foo xyz baz bar"
  gsub_ "foo bar baz bar 123" "bar" "xyz"
  assert_eq "$RESULT" "foo xyz baz xyz 123"
  # The search string and the replacement are taken literally.
  sub_ "a*b?c a*b?c" "*b?" "[&]"
  assert_eq "$RESULT" "a[&]c a*b?c"
  gsub_ "a*b?c a*b?c" "*b?" "[&]"
  assert_eq "$RESULT" "a[&]c a[&]c"
  index_ "peanut" "an"
  assert_eq "$RESULT" 3

  echo OK. >&2
}

#endregion 

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ string
then
  set -o nounset -o errexit
  test_lib_string_sh "$@"
fi
