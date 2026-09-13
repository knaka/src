#!/usr/bin/env bash
set -- _d8e38fa "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

git_co_default() {
  if git show-ref --verify --quiet refs/heads/master
  then
    git checkout master
  elif git show-ref --verify --quiet refs/heads/main
  then
    git checkout main
  else
    echo "Neither \"master\" nor \"main\" branch found." >&2
    exit 1
  fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 git_co_default "$@"
fi
