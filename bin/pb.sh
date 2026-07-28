#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_PB_SH && return # shpp:source_guard

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./gc.sh
. ./sc.sh
cd "$1"; shift 2

pb() {
  if test -t 0
  then
    gc
  else
    sc
  fi
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.pb.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  pb "$@"
fi
