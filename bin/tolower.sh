#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b77f41d-false}" && return 0; sourced_b77f41d=true

tolower() {
  tr '[:upper:]' '[:lower:]'
}

case "${0##*/}" in
  (tolower.sh|tolower)
    set -o nounset -o errexit
    tolower "$@"
    ;;
esac
