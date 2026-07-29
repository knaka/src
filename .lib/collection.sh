#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_COLLECTION_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

vec_() {
  if test "$#" -eq 0
  then
    echo_ ""
    return
  fi
  printf_ "%s${CH_US}" "$@"
}

vempty() {
  test -z "$1"
}

vsort_nul_() {
  echo_ "$(
    printf "%s" "$1" \
    | tr "$CH_US" '\0' \
    | "$2" \
    | tr '\0' "$CH_US" \
    #nop
  )"
}

sort_9835641() {
  sort -z
}

vsort_() {
  vsort_nul_ "$1" sort_9835641
}

shuf_28cd8b4() {
  sort -z -R
}

vshuf_() {
  vsort_nul_ "$1" shuf_28cd8b4
}

map_() {
  vec_ "$@"
}

veach() {
  local func="${2-_}"
  local item
  local IFS="$CH_US"
  for item in $1
  do
    unset IFS
    "$func" "$item"
  done
}

# Put a value in an associative array.
mput_() {
  local sep="$CH_US"
  OPTIND=1; while getopts _-:s: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (s|sep|separator) sep="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local key="$2"
  local value="$3"
  local IFS="$sep"
  # shellcheck disable=SC2086
  set -- $1
  local i=0
  local n=$(($#/2))
  while test "$i" -lt "$n"
  do
    test "$1" != "$key" && set -- "$@" "$1" "$2"
    shift 2
    i=$((i+1))
  done
  set -- "$@" "$key" "$value"
  printf_ "%s$sep%s$sep" "$@"
}

# Get a value from an associative array.
mget_() {
  local sep="$CH_US"
  OPTIND=1; while getopts _-:s: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (s|sep|separator) sep="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local key="$2"
  local IFS="$sep"
  # shellcheck disable=SC2086
  set -- $1
  local i=0
  local n=$(($#/2))
  while test "$i" -lt "$n"
  do
    test "$1" = "$key" && echo_ "$2" && return 0
    shift 2
    i=$((i+1))
  done
  return 1
}

# Keys of an associative array implemented as a property list.
mkeys_() {
  local sep="$CH_US"
  OPTIND=1; while getopts _-:s: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (s|sep|separator) sep="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local IFS="$sep"
  # shellcheck disable=SC2086
  set -- $1
  local i=0
  local n=$(($#/2))
  while test "$i" -lt "$n"
  do
    set -- "$@" "$1"
    shift 2
    i=$((i+1))
  done
  printf_ "%s$sep" "$@"
}

collection() {
  local sep="#"
  local RESULT=
  echo_ ""
  mput_ -s"$sep" "$RESULT" "key" "value"
  echo "$RESULT"
  mput_ -s"$sep" "$RESULT" "key" "value  x  y${CH_LF}value${CH_TAB}z"
  echo "$RESULT"
  mget_ -s"$sep" "$RESULT" "key"
  echo "80745a9 $RESULT"
  mput_ -s"$sep" "$RESULT" "bar" "BAR"
  mkeys_ -s"$sep" "$RESULT"
  echo 759f2ba "$RESULT"
  local IFS="$sep"
  local arg
  for arg in $RESULT
  do
    echo "442f931 <$arg>"
  done
  unset IFS
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ collection
then
  set -o nounset -o errexit
  collection "$@"
fi
