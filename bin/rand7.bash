#!/usr/bin/env bash
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
"${sourced_f967886-false}" && return 0; sourced_f967886=true

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.lib.bash
popd >/dev/null || exit 1

# Generates a random 7-digit hexadecimal number
rand7() {
  local seed
  if test -r /dev/urandom
  then
    # Generate seed from /dev/urandom if available
    seed=$(od -An -N4 -tu4 </dev/urandom | tr -d ' ')
  elif is_macos
  then
    # Generate seed from current timestamp on macOS in second precision
    seed=$(date +%s)
  else
    # Generate seed from nanoseconds since epoch on other platforms
    seed=$(date +%N)
  fi
  # 0.0 <= rand() < 1.0
  # 268435456 = 0xFFFFFFF + 1
  # Hexadecimal integer literal is available only on GAwk.
  awk -v seed="$seed" 'BEGIN { srand(seed); printf "%07x\n", int(rand() * 268435456) }'
}

case "${0##*/}" in
  ("${BASH_SOURCE[0]##*/}"|"${BASH_SOURCE[0]##*/}".bash)
    set -o nounset -o errexit
    rand7 "$@"
    ;;
esac
