#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_MDPP_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

launch_mdpp() {
  command mdpp "$@"
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (mdpp.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  launch_mdpp "$@"
fi
