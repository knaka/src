# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 2a9cd0d && return 0

dec_to_hex() {
  printf "0x%X\n" "$@"
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ dec_to_hex || _ 10to16
then
  set -o nounset -o errexit
  dec_to_hex "$@"
fi
