#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_fcad6c8-false}" && return 0; sourced_fcad6c8=true

# cowsay - npm https://www.npmjs.com/package/cowsay
cowsay_version_14ac6ce=1.6.0

set_cowsay_version() {
  cowsay_version_14ac6ce="$1"
}

# Releases · nodejs/node https://github.com/nodejs/node/releases
cowsay_node_version_07c311e=

set_cowsay_node_version() {
  cowsay_node_version_07c311e="$1"
}

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./node.lib.sh
cd "$1"; shift 2

cowsay() {
  run_npm_pkg --node-version="$cowsay_node_version_07c311e" "cowsay@$cowsay_version_14ac6ce" -- "$@" "$@"
}

case "${0##*/}" in
  (cowsay.sh|cowsay)
    set -o nounset -o errexit
    cowsay "$@"
    ;;
esac
