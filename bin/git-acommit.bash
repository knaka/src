#!/usr/bin/env bash
set -- _BIN_GIT_ACOMMIT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Git Amend-commit

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

git_acommit() {
  tail_exec git commit --amend --no-edit "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 git_acommit "$@"
fi
