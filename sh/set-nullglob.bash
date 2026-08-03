#!/usr/bin/env bash
set -- _03d3433 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

use_nullglob() {
  local retcmds="trap - RETURN"
  trap 'eval "$retcmds"' RETURN

  if ! shopt -p nullglob >/dev/null
  then
    shopt -s nullglob
    retcmds="shopt -u nullglob; $retcmds"
  fi

  echo -n "Do something with: "
  shopt -p nullglob || :
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail

  echo -n "Before: "
  shopt -p nullglob || :

  use_nullglob

  echo -n "After: "
  shopt -p nullglob || :

  shopt -s nullglob

  echo -n "Before: "
  shopt -p nullglob || :

  use_nullglob

  echo -n "After: "
  shopt -p nullglob || :
fi
