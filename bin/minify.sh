#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ef0f5d6-false}" && return 0; sourced_ef0f5d6=true

minify() {
  # awk
  # sed -E -e 's/^[[:space:]]*#.*//; s/^[[:space:]]+//; s/([^{};])$/\1;/' | tr -d '\n'
  # jq
  sed -E -e 's/^[[:space:]]*#.*//; s/^[[:space:]]+//; s/^([^[:space:]])/ \1/' | tr -d '\n' | sed 's/ *//'
}

case "${0##*/}" in
  (minify.sh|minify)
    set -o nounset -o errexit
    minify "$@"
    ;;
esac
