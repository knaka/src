#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ d899d96 && return 0

# test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
# if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
# set -- _LIBDIR ./.lib "$@"
# . ./.lib/utils.sh
# shift 2
# cd "$1" || exit 1; shift

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
