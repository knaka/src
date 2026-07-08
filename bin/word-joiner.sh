#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 0ff1f71 && return 0

word_joiner() {
  # ⁠ - ワードジョイナー, U+2060, 一般句読点 (◕‿◕) SYMBL https://symbl.cc/jp/2060/
  printf "⁠" 
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ word_joiner || _ word-joiner
then
  set -o nounset -o errexit
  word_joiner "$@"
fi
