#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_OP_SH && return # shpp:source_guard

op() {
  if command -v Powershell >/dev/null 2>&1
  then
    exec pwsh.exe -Command "Start-process" "$@"
  elif command -v open >/dev/null 2>&1
  then
    exec open "$@"
  elif command -v xdg-open >/dev/null 2>&1
  then
    exec xdg-open "$@"
  elif command -v cygstart >/dev/null 2>&1
  then
    exec cygstart "$@"
  elif command -v start >/dev/null 2>&1
  then
    exec start "$@"
  elif command -v gnome-open >/dev/null 2>&1
  then
    exec gnome-open "$@"
  elif command -v kde-open >/dev/null 2>&1
  then
    exec kde-open "$@"
  elif command -v xdg-open >/dev/null 2>&1
  then
    exec xdg-open "$@"
  fi
  echo "No command found to open the file."
  exit 1
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.op.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  op "$@"
fi
