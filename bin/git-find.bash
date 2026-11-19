#!/usr/bin/env bash
set -- _BIN_GIT_FIND_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Print the paths of the files that appear in the history of the current branch and match the pathspecs given. The files deleted or renamed since are also printed, which helps to find a file that is no longer in the working tree. With "--all", search the history of all refs instead of only the current branch.
# Usage: git_find [--all] [pathspec...]
# Example: git_find '*.md'
git_find() {
  local all_opt=
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (all) all_opt="--all";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  git log ${all_opt:+"$all_opt"} --format= --name-only -- "$@" | sort -u
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 git_find "$@"
fi
