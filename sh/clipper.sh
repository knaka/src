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

# Releases · nodejs/node https://github.com/nodejs/node/releases
clipper_node_version_c4da3a4=

set_clipper_node_version() {
  clipper_node_version_c4da3a4="$1"
}

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./node.lib.sh
cd "$1"; shift 2

clipper() {
  run_npm_pkg --node-version="$clipper_node_version_c4da3a4" "@philschmid/clipper@$clipper_version_2b8a94e" -- "$@"
}

case "${0##*/}" in
  (clipper.sh|clipper)
    set -o nounset -o errexit
    clipper "$@"
    ;;
esac
