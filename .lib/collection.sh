#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ LIB_COLLECTION_SH && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
shift 2
cd "$1" || exit; shift

hoge() {
  _
}

vec_() {
  if test "$#" -eq 0
  then
    set_result ""
    return
  fi
  set_resultf "%s${ch_us}" "$@"
}

vempty() {
  test -z "$1"
}

vsort_() {
  set_result "$(printf "%s" "$1" | tr "$ch_us" '\0' | sort -z | tr '\0' "$ch_us")"
}

map_() {
  vec_ "$@"
}

veach() {
  local func="${2-_}"
  local IFS="$ch_us"
  local item
  for item in $1
  do
    "$func" "$item"
  done
}

# Put a value in an associative array.
mput_() {
  local sep="$ch_us"
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
  set_resultf "%s$sep%s$sep" "$@"
}

# Get a value from an associative array.
mget_() {
  local sep="$ch_us"
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
    test "$1" = "$key" && set_result "$2" && return 0
    shift 2
    i=$((i+1))
  done
  return 1
}

# Keys of an associative array implemented as a property list.
mkeys_() {
  local sep="$ch_us"
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
  set_resultf "%s$sep" "$@"
}

# map_put_

map() {
  local sep="#"
  local RESULT=
  set_result ""
  mput_ -s"$sep" "$RESULT" "key" "value"
  echo "$RESULT"
  mput_ -s"$sep" "$RESULT" "key" "value  x  y${ch_lf}value${ch_tab}z"
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

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ map
then
  set -o nounset -o errexit
  map "$@"
fi
