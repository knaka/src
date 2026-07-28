#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_MISE_SELF_UPDATE_SH && return # shpp:source_guard

mise_self_update() {
  mise self-update "$@"
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.mise-self-update.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  mise_self_update "$@"
fi
