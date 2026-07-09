#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ d899d96 && return 0

# Convenient for cleaning logs.
strip_escape_sequences() {
  # ANSI escape code - Wikipedia https://en.wikipedia.org/wiki/ANSI_escape_code
  # BusyBox sed(1) does not accept `\octal` or `\xhex`.
  sed -E -e 's/\[[0-9;]*[ABCDEFGHJKSTmin]//g'
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ strip_escape_sequence
then
  set -o nounset -o errexit
  strip_escape_sequence "$@"
fi
