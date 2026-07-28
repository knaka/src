#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_URLREC_SH && return # shpp:source_guard

# Fetches the given URL(s) and prints all linked URLs found on each page
# that are under the same URL prefix (i.e. sub-paths of the given URL).

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # shpp:end_source

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.urlrec.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  urlrec "$@"
fi
