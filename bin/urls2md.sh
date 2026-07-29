#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_URLS2MD_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

# Read URLs from standard input, summarize the corresponding web page content with Readability, and output as a single concatenated Markdown document. Error handling is not implemented. Please notify the #discussion channel on Slack before making extensions or modifications.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./clipper.sh
cd "$3" || exit; shift 3 # /shpp:sources

init_temp_dir

urls2md() {
  local temp_file="$TEMP_DIR"/temp.md
  while read -r url
  do
    echo "$url" >&2
    clipper clip -u "$url" -o "$temp_file"
    sed -E -e "s@^# (.*)\$@# [\1]($url)@" "$temp_file"
    echo
  done
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (urls2md.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  urls2md "$@"
fi
