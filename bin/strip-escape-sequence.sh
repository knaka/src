#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_STRIP_ESCAPE_SEQUENCE_SH && return # shpp:source_guard

# Convenient for cleaning logs.
strip_escape_sequences() {
  # ANSI escape code - Wikipedia https://en.wikipedia.org/wiki/ANSI_escape_code
  # BusyBox sed(1) does not accept `\octal` or `\xhex`.
  sed -E -e 's/\[[0-9;]*[ABCDEFGHJKSTmin]//g'
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.strip-escape-sequence.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  strip_escape_sequence "$@"
fi
