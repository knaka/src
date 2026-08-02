#!/usr/bin/env sh
set -- __LIB_SHPP_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
script_ccd23eb="$PWD"/shpp.pl
cd "$3" || exit; shift 3 # /shpp:sources

shpp() {
  local in_place=false
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (in-place) in_place=true;;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local pwd
  pwd="$(realpath "$PWD")"
  local file
  for file in "$@"
  do
    shift
    file="$(realpath "$file")"
    file="${file#"$pwd/"}"
    set -- "$@" "$file"
  done
  "$in_place" && set -- --in-place "$@"
  perl "$script_ccd23eb" "$@"
}
