#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c48b48e-false}" && return 0; sourced_c48b48e=true

# Run Clipper, a command-line tool to summarize web pages into Markdown format. // philschmid/clipper.js: HTML to Markdown converter and crawler. https://github.com/philschmid/clipper.js

# @philschmid/clipper - npm https://www.npmjs.com/package/@philschmid/clipper
clipper_version_2b8a94e=0.2.0

set_clipper_version() {
  clipper_version_2b8a94e="$1"
}

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

clipper() {
  mise exec npm:"@philschmid/clipper@$clipper_version_2b8a94e" -- clipper "$@"
}

case "${0##*/}" in
  (clipper.sh|clipper)
    set -o nounset -o errexit
    clipper "$@"
    ;;
esac
