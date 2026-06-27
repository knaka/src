# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 76537ad && return 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
popd >/dev/null || exit 1

git-grep() {
  local all_opt=""
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (all) all_opt="--all";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
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
  shift
  {
    # Search in commit logs
    git log $all_opt $color_opt --regexp-ignore-case --grep="$pattern"
    # Then search in diffs if paths are specified
    if test $# -gt 0
    then
      echo
      echo ----------------------------------------------------------------------------
      echo
      git log $all_opt $color_opt -G"$pattern" --patch -- "$@"
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
  git-grep "$@"
fi
