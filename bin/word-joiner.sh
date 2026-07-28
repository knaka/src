#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_WORD_JOINER_SH && return # shpp:source_guard

word_joiner() {
  # ⁠ - ワードジョイナー, U+2060, 一般句読点 (◕‿◕) SYMBL https://symbl.cc/jp/2060/
  printf "⁠" 
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.word-joiner.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  word_joiner "$@"
fi
