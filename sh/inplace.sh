#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_0cc00a5-}" = true && return 0; sourced_0cc00a5=true
set -o nounset -o errexit

# Usage:
#   inplace [options] regex_pattern file_paths...
#   inplace [options] -e regex_pattern [-e regex_pattern]... file_paths...
# Options:
#   -n, --dry-run: Print the changes without modifying the files.

dry_run=false
OPTIND=1; while getopts n-: OPT
do
  if test "$OPT" = "-"
  then
    OPT="${OPTARG%%=*}"
    # shellcheck disable=SC2030
    OPTARG="${OPTARG#"$OPT"}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    (n|dry-run) dry_run=true;;
    (\?) exit 1;;
    (*) echo "Unexpected option: $OPT" >&2; exit 1;;
  esac
done
shift $((OPTIND-1))

# e_arg=false
# for arg in "$@"
# do
#   if test "$arg" = -- "-e"
#   then
#     e_arg=true
#   elif "$e_arg"
#   then
#     arg="$(echo "$arg" | sed -e 's///g')"
#     e_arg=false
#   fi
#   set -- "$@" "$arg"
#   shift
# done

if ! "$dry_run"
then
  set -- -i '' "$@"
fi

sed -E "$@"
