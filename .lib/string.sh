#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ LIB_STRING_SH && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 
case "${1:+$1}" in (_LIBDIR) cd "$2" || exit 1;; (*) cd "$_APPDIR" || exit 1;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit 1; shift

# AWK-like string functions not using subshell.

: "${RESULT-}"

result_name_9a2b2db=RESULT

set_result_name() {
  result_name_9a2b2db="$1"
}

set_result() {
  eval "$result_name_9a2b2db=\$1"
}

toupper_() {
  # shellcheck disable=SC3059
  is_bash4_bin && set_result "${1^^}" && return
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
  set_result "$result"
}

tolower_() {
  # shellcheck disable=SC3059
  is_bash4_bin && set_result "${1,,}" && return
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
  set_result "$result"
}

substr_() {
  local result=
  local s="$1"
  local start="$2"
  local length="${3-${#s}}"
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
  set_result "$result"
}

sub_() {
  local s="$1"
  local from="$2"
  test -z "$from" && set_result "$s" && return
  local to="$3"
  # shellcheck disable=SC3060
  is_bash_bin && set_result "${s/$from/$to}" && return
  local left="${s%%"$from"*}"
  test "$left" = "$s" && set_result "$s" && return
  set_result "$left$to${s#*"$from"}"
}

gsub_() {
  local result=
  local s="$1"
  local from="$2"
  test -z "$from" && set_result "$s" && return
  local to="$3"
  # shellcheck disable=SC3060
  is_bash_bin && set_result "${s//$from/$to}" && return
  while test -n "$s"
  do
    local left="${s%%"$from"*}"
    test "$left" = "$s" && result="$result$s" && break
    result="$result$left$to"
    s="${s#*"$from"}"
  done
  set_result "$result"
}

index_() {
  local s="$1"
  local find="$2"
  test -z "$find" && set_result 0 && return
  local left="${s%%"$find"*}"
  test "$left" = "$s" && set_result 0 && return
  set_result $((${#left}+1))
}

length_() {
  set_result ${#1}
}

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

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ string
then
  set -o nounset -o errexit
  toupper_ "aBc"
  test "$RESULT" = "ABC"
  tolower_ "AbC"
  test "$RESULT" = "abc"
  substr_ "123456789" 4 3
  test "$RESULT" = "456"
  sub_ "foo bar baz bar" "bar" "xyz"
  test "$RESULT" = "foo xyz baz bar"
  gsub_ "foo bar baz bar 123" "bar" "xyz"
  test "$RESULT" = "foo xyz baz xyz 123"
  index_ "peanut" "an"
  test "$RESULT" -eq 3

  echo Done >&2
fi
