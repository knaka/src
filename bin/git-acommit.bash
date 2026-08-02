#!/usr/bin/env bash
set -- _BIN_GIT_ACOMMIT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Git Amend-commit

git_acommit() {
  git commit --amend --no-edit "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  git_acommit "$@"
fi
