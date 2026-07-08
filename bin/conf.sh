#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 5ca1189 && return 0

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.sh
. ./.lib/commands.sh
shift 2
cd "$1" || exit 1; shift 2

conf() {
  local source_path="$HOME"/.local/share/chezmoi
  local mode="file"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (source) source_path="$OPTARG";;
      (mode) mode="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; exit 1;;
    esac
  done

  local found_subcmd=false
  local arg
  for arg in "$@"
  do
    shift
    if ! "$found_subcmd"
    then
      case "${arg}" in
        (-*)
          ;;
        (*)
          found_subcmd=true
          set -- "$@" --mode="$mode" --source="$source_path"
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

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ conf
then
  set -o nounset -o errexit
  set -- --source="$HOME/repos/github.com/knaka/src/conf/source" "$@"
  set -- --mode="symlink" "$@"
  conf "$@"
fi
