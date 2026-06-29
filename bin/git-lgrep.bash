# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 76537ad && return 0

# Git Log Grep

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
popd >/dev/null || exit 1

git_lgrep() {
  local all_opt=""
  local i_opt=""
  OPTIND=1; while getopts _i-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (all) all_opt="--all";;
      (i|regexp-ignore-case) i_opt="-i";;
      (?) exit 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  local pattern="$1"
  shift

  local color_opt=--color=never
  if is_terminal
  then
    color_opt=--color
  fi
  {
    # Search in commit logs
    git log $all_opt $i_opt $color_opt --regexp-ignore-case --grep="$pattern" \
    | awk '{ print; found=1 } END { if (!found) print "(No commit message matches)" }' \
    || :
    # Then search in diffs if paths are specified
    if test $# -gt 0
    then
      echo
      echo ----------------------------------------------------------------------------
      echo

      git grep $i_opt $color_opt "$pattern" -- "$@" \
      | awk '{ print; found=1 } END { if (!found) print "(No work file matches)" }' \
      || :

      echo
      echo ----------------------------------------------------------------------------
      echo
      git log $all_opt $i_opt $color_opt -G"$pattern" --patch -- "$@" \
      | awk '{ print; found=1 } END { if (!found) print "(No change matches)" }' \
      || :
    fi
  } \
  | if is_terminal
  then
    less --raw-control-chars
  else
    cat
  fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  git_lgrep "$@"
fi
