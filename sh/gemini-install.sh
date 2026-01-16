#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_dde9200-false}" && return 0; sourced_dde9200=true

# Gemini CLI installation, execution, and deployment | Gemini CLI https://geminicli.com/docs/get-started/installation/

gemini_install() {
  npm i -g @google/gemini-cli
}

case "${0##*/}" in
  (gemini-install.sh|gemini-install)
    set -o nounset -o errexit
    gemini_install "$@"
    ;;
esac
