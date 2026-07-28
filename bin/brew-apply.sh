#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_BREW_APPLY_SH && return # shpp:source_guard

# Idempotently installs and uninstalls packages based on the declarative ~/.Brewfile.
brew_apply() {
  brew bundle --global --cleanup install "$@"
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.brew-apply.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  brew_apply "$@"
fi
