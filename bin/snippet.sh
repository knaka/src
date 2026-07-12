#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_39e61b5-false}" && return 0; sourced_39e61b5=true

snippet() {
  # shellcheck disable=SC2016
  sed -E \
    -e 's/\\/_220b91b_/g' \
    -e 's/"/\\"/g' \
    -e 's/(\\[0-9a-z])/\\\1/g' \
    -e 's/\t/\\t/g' \
    -e 's/\$/\\\\$/g' \
    -e 's@_asterisk_slash_@*/@g' \
    -e 's/^(.*)$/"\1",/' \
    -e 's@_rand7_@${RANDOM_HEX}${RANDOM_HEX/^(.).*/$1/}@g' \
    -e 's/foobar/${1}/g' \
    -e 's/_tabstop_\(([^)]+)\)/${1\1}/g' \
    -e 's/_tabstop_\[([^]]+)\]/${1\1}/g' \
    -e 's/_tabstop_/${1}/g' \
    -e 's/_220b91b_/\\\\\\\\/g' \
    -e 's/^/\t\t\t/'
}

case "${0##*/}" in
  (snippet.sh|snippet)
    set -o nounset -o errexit
    snippet "$@"
    ;;
esac
