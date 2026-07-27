#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_102a099-false}" && return 0; sourced_102a099=true

# Fetches the given URL(s) and prints all linked URLs found on each page
# that are under the same URL prefix (i.e. sub-paths of the given URL).

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3

urlrec() {
  init_temp_dir
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
