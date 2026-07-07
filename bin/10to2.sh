# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 7595e3f && return 0

dec_to_bin() {
  local dec
  for dec in "$@"
  do
    local bin=
    while test "$dec" -gt 0
    do
      bin=$((dec % 2))$bin
      dec=$((dec / 2))
    done
    echo "${bin:-0}"
  done
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ dec_to_bin || _ 10to2
then
  set -o nounset -o errexit
  dec_to_bin "$@"
fi
