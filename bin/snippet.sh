#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_SNIPPET_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (snippet.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  snippet "$@"
fi
