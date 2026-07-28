#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_URLS2MD_SH && return # shpp:source_guard

# Read URLs from standard input, summarize the corresponding web page content with Readability, and output as a single concatenated Markdown document. Error handling is not implemented. Please notify the #discussion channel on Slack before making extensions or modifications.

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./clipper.sh
cd "$1"; shift 2

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.urls2md.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  urls2md "$@"
fi
