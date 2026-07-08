#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 7952163 && return 0

field() {
  # Print 1-indexed n-th field of input lines.
  awk "{ print \$${1}} "
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ field
then
  set -o nounset -o errexit
  field "$@"
fi
