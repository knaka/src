# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 4bd1333 && return 0

hex_to_dec() {
  local hex
  for hex in "$@"
  do
    hex="${hex#0x}"
    hex="0x$hex"
    printf "%d\n" "$hex"
  done
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ hex_to_dec | _ 16to10
then
  set -o nounset -o errexit
  hex_to_dec "$@"
fi
