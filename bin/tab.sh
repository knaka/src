#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_TAB_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

tab() {
  printf "\t"
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (tab.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  tab "$@"
fi
