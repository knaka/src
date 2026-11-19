#!/usr/bin/env bash
set -- _BIN_GIT_DIFFS_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

git_diffs() {
  git log --patch -- "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 git_diffs "$@"
fi
