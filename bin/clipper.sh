#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_CLIPPER_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

# Run Clipper, a command-line tool to summarize web pages into Markdown format. // philschmid/clipper.js: HTML to Markdown converter and crawler. https://github.com/philschmid/clipper.js

# @philschmid/clipper - npm https://www.npmjs.com/package/@philschmid/clipper
clipper_version_2b8a94e=0.2.0

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
is_mise || . ../.lib/commands.sh
cd "$3" || exit; shift 3 # /shpp:sources

set_clipper_version() {
  clipper_version_2b8a94e="$1"
}

clipper() {
  mise exec npm:"@philschmid/clipper@$clipper_version_2b8a94e" -- clipper "$@"
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (clipper.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  clipper "$@"
fi
