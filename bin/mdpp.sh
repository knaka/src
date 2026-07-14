#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 4ba6c5f && return

launch_mdpp() {
  command mdpp "$@"
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ mdpp
then
  set -o nounset -o errexit
  launch_mdpp "$@"
fi
