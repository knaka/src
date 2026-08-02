#!/usr/bin/env bash
set -- _03d3433 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

nullglob() {
  echo -n "Before: "
  shopt -p nullglob || :

  local unset_nullglob=false
  ! shopt -p nullglob >/dev/null && shopt -s nullglob && unset_nullglob=true

  echo -n "Do something while: "
  shopt -p nullglob || :

  "$unset_nullglob" && shopt -u nullglob

  echo -n "After: "
  shopt -p nullglob || :

}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  nullglob "$@"
fi
