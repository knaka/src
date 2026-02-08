#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_7ed32ff-false}" && return 0; sourced_7ed32ff=true

#MISE description="Show environment variables."

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" || exit 1; fi
set -- _LIBDIR . "$@"
. ./utils.libsh
shift 2
cd "$1" || exit 1; shift 2

env() {
  if is_windows
  then
    echo "On Windows." >&2
  fi
  command env
}

case "${0##*/}" in
  (env.sh|env)
    set -o nounset -o errexit
    env "$@"
    ;;
esac
