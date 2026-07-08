#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 0b3c186 && return 0

# Idempotently installs and uninstalls packages based on the declarative ~/.Brewfile.
brew_apply() {
  brew bundle --global --cleanup install "$@"
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ brew_apply || _ brew-apply
then
  set -o nounset -o errexit
  brew_apply "$@"
fi
