#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c48b48e-false}" && return 0; sourced_c48b48e=true

# Run Clipper, a command-line tool to summarize web pages into Markdown format. // philschmid/clipper.js: HTML to Markdown converter and crawler. https://github.com/philschmid/clipper.js

# @philschmid/clipper - npm https://www.npmjs.com/package/@philschmid/clipper
clipper_version_2b8a94e=0.2.0

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
is_mise || . ../.lib/commands.sh
cd "$3" || exit; shift 3

set_clipper_version() {
  clipper_version_2b8a94e="$1"
}

clipper() {
  mise exec npm:"@philschmid/clipper@$clipper_version_2b8a94e" -- clipper "$@"
}

case "${0##*/}" in
  (clipper.sh|clipper)
    set -o nounset -o errexit
    clipper "$@"
    ;;
esac
