#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_904b441-false}" && return 0; sourced_904b441=true

sort_ignoring_comment() {
  sed -Ee 's/^(#[[:blank:]]*)(.*)$/\2 aa3700a \1/' | sort | sed -Ee 's/(.*) aa3700a (.*)/\2\1/'
}

case "${0##*/}" in
  (sort-ignoring-comment.sh|sort-ignoring-comment)
    set -o nounset -o errexit
    sort_ignoring_comment "$@"
    ;;
esac
