#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ef0f5d6-false}" && return 0; sourced_ef0f5d6=true

# set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
# set -- _LIBDIR . "$@"
# shift 2
# cd "$1" || exit 1; shift 2

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
