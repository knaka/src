#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_102a099-false}" && return 0; sourced_102a099=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

urlrec() {
  local url
  for url in "$@"
  do
    echo "$url"
    curl --silent --fail "$url" \
    | htmlq --base="$url" 'a[href]' --attribute=href \
    | sed -e 's/#.*//' \
    | grep "$url"
  done \
  | sort \
  | uniq
}

case "${0##*/}" in
  (urlrec.sh|urlrec)
    set -o nounset -o errexit
    urlrec "$@"
    ;;
esac
