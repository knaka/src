#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4b40a17-false}" && return 0; sourced_4b40a17=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

set -o nounset -o errexit

# Basename without extension
base="${0##*/}"
base="${base##*\\}"
base="${base%.sh}"

if ! type "$base" 2>/dev/null | grep -q -E -e "a (shell )?function"
then
  echo "No matching function for \"$base\"." >&2
  exit 1
fi

"$base" "$@"
