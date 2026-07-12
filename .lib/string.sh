#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 95ac582 && return 0

# AWK-like string functions not using subshell.

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit 1; shift

result_name_9a2b2db=RESULT

set_result_name() {
  result_name_9a2b2db="$1"
}

set_result() {
  eval "$result_name_9a2b2db=\$1"
}

toupper_() {
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
  local result=
  local s="$1"
  local from="$2"
  test -z "$from" && set_result "$s" && return 0
  local to="$3"
  local c
  while test -n "$s"
  do
    case "$s" in
      ("$from"*)
        result="$result$to"
        substr_ "$s" $((${#from}+1))
        eval "result=\"\$result\$$result_name_9a2b2db\""
        break
        ;;
      (*)
        c="${s%"${s#?}"}"
        s="${s#?}"
        result="${result}$c"
        ;;
    esac
  done
  set_result "$result"
}

gsub_() {
  local result=
  local s="$1"
  local from="$2"
  test -z "$from" && set_result "$s" && return 0
  local to="$3"
  local left
  while test -n "$s"
  do
    left=${s%%"$from"*}
    if test "$left" = "$s"
    then
      result="$result$s"
      break
    fi
    result="$result$left$to"
    s="${s#*"$from"}"
  done
  set_result "$result"
}

index_() {
  local result=0
  local s="$1"
  local find="$2"
  test -z "$find" && set_result "$result" && return 0
  local processed=
  while test -n "$s"
  do
    case "$s" in
      ("$find"*)
        result=$((${#processed}+1))
        break
        ;;
      (*)
        s="${s#?}"
        processed="${processed}x"
        ;;
    esac
  done
  set_result "$result"
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
