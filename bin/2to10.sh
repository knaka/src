# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 18d1532 && return 0

bin_to_dec() {
  local bin
  for bin in "$@"
  do
    local dec=0
    while :
    do
      if test -z "$bin"
      then
        printf "%d\n" "$dec"
        continue 2
      fi
      local digit
      digit="${bin%"${bin#?}"}"
      bin="${bin#?}"
      dec=$((dec * 2 + digit))  
    done
  done
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ bin_to_dec || _ 2to10
then
  set -o nounset -o errexit
  bin_to_dec "$@"
fi
