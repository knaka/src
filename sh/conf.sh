#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_88f1f74-false}" && return 0; sourced_88f1f74=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
. ./chezmoi.lib.sh
cd "$1"; shift 2

conf() {
  local found_subcmd=false
  local arg
  for arg in "$@"
  do
    shift
    if ! "$found_subcmd"
    then
      case "${arg}" in
        (-*)
          set -- "$@" "$arg"
          ;;
        (*)
          found_subcmd=true
          if test "${CHEZMOISOURCEDIR+set}" = set
          then
            set -- "$@" --source="$CHEZMOISOURCEDIR"
          fi
          case "$arg" in
            (ed|edit)
              set -- "$@" edit --watch
              ;;
            (*)
              set -- "$@" "$arg"
              ;;
          esac
          ;;
      esac
    else
      set -- "$@" "$arg"
    fi
  done
  chezmoi "$@"
}

case "${0##*/}" in
  (conf.sh|conf)
    set -o nounset -o errexit
    conf "$@"
    ;;
esac
