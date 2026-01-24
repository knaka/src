#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ccdd5af-false}" && return 0; sourced_ccdd5af=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
. ./node.lib.sh
cd "$1"; shift 2

claude_install() {
  npm i -g @anthropic-ai/claude-code
}

case "${0##*/}" in
  (claude-install.sh|claude-install)
    set -o nounset -o errexit
    claude_install "$@"
    ;;
esac
