#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_39e61b5-false}" && return 0; sourced_39e61b5=true

codesnippet() {
  sed -E \
    -e 's/"/\\"/g' \
    -e 's/(\\[0-9a-z])/\\\1/g' \
    -e 's/\t/\\t/g' \
    -e 's/\$/\\\\$/g' \
    -e 's/^(.*)$/"\1",/' \
    -e 's/^/\t\t\t/'
}

case "${0##*/}" in
  (codesnippet.sh|codesnippet)
    set -o nounset -o errexit
    codesnippet "$@"
    ;;
esac
