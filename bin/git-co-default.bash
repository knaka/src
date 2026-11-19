#!/usr/bin/env bash
set -- _BIN_GIT_CO_DEFAULT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

git_co_default() {
  local branch
  for branch in master main
  do
    git show-ref --verify --quiet "refs/heads/$branch" || continue
    git checkout "$branch"
    return 0
  done
  echo 'Neither "master" nor "main" branch found.' >&2
  return 1
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 git_co_default "$@"
fi
