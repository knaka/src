#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_dde9200-false}" && return 0; sourced_dde9200=true

# Gemini CLI installation, execution, and deployment | Gemini CLI https://geminicli.com/docs/get-started/installation/

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./task.sh
. ./node.lib.sh
cd "$1"; shift 2

gemini_install() {
  npm i -g @google/gemini-cli
}

case "${0##*/}" in
  (gemini-install.sh|gemini-install)
    set -o nounset -o errexit
    gemini_install "$@"
    ;;
esac
