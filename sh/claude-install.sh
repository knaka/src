#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ccdd5af-false}" && return 0; sourced_ccdd5af=true

claude_install() {
  npm i -g @anthropic-ai/claude-code
}

case "${0##*/}" in
  (claude-install.sh|claude-install)
    set -o nounset -o errexit
    claude_install "$@"
    ;;
esac
