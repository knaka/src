#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_102a099-false}" && return 0; sourced_102a099=true

# Fetches the given URL(s) and prints all linked URLs found on each page
# that are under the same URL prefix (i.e. sub-paths of the given URL).

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

urlrec() {
  register_temp_cleanup
  local html="$TEMP_DIR"/18a7cf8.html
  local urls="$TEMP_DIR"/4606904.txt
  local url
  for url in "$@"
  do
    echo "$url"
    curl --silent --fail "$url" >"$html"
    htmlq --filename="$html" --base="$url" 'a[href]' --attribute=href \
    | sed -e 's/#.*//' \
    | grep --fixed-strings "$url" || :
  done >"$urls"
  sort "$urls" | uniq
}

case "${0##*/}" in
  (urlrec.sh|urlrec)
    set -o nounset -o errexit
    urlrec "$@"
    ;;
esac
