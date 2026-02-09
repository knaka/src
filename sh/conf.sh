#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_88f1f74-false}" && return 0; sourced_88f1f74=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

export CHEZMOISOURCEDIR="$HOME/repos/github.com/knaka/src/conf/chezmoi-source"

conf() {
  local found_chezmoi_subcmd=false
  local arg
  for arg in "$@"
  do
    shift
    if ! "$found_chezmoi_subcmd"
    then
      case "${arg}" in
        (-*)
          ;;
        (*)
          found_chezmoi_subcmd=true
          if test "${CHEZMOISOURCEDIR+set}" = set
          then
            set -- "$@" --source="$CHEZMOISOURCEDIR"
          fi
          case "$arg" in
            (ed|edit)
              set -- "$@" edit --watch
              continue
              ;;
            (*)
              ;;
          esac
          ;;
      esac
    fi
    set -- "$@" "$arg"
  done
  chezmoi "$@"
}

case "${0##*/}" in
  (conf.sh|conf)
    set -o nounset -o errexit
    conf "$@"
    ;;
esac
