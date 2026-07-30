#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_GIT_RM_UNTRACKED_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

# Remove untracked files in the git work of the current directory.
git_rm_untracked() {
  git clean -d --force
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (git-rm-untracked.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  git_rm_untracked "$@"
fi
