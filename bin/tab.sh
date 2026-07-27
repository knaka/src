#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f352301-false}" && return 0; sourced_f352301=true

tab() {
  printf "\t"
}

case "${0##*/}" in
  (tab.sh|tab)
    set -o nounset -o errexit
    tab "$@"
    ;;
esac
