#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_6049c10-false}" && return 0; sourced_6049c10=true
set -o nounset -o errexit

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
shift 2
cd "$1" || exit 1; shift 2

# `idea.bat` launches the IDE with java.exe, not idea64.exe. Which confuses AHK.
ide_cmd_path() {
  find \
    "C:/Program Files"/JetBrains/IntelliJ*/bin/idea64.exe | sort -rn | while read -r dir_path
  do
    if test -f "$dir_path"
    then
      echo "$dir_path"
      return 0
    fi
  done
  exit 1
}

if is_windows
then
  "$(ide_cmd_path)" "$@"
  exit 1
fi

exec idea "$@"
