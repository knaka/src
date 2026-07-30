#!/usr/bin/env sh
set -- _BIN_TOUCHBASH_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

commit_with_message() {
  local temp_file
  temp_file="$(mktemp)"
  printf "%s" "$1" >"$temp_file"
  code --wait "$temp_file"
  if test -s "$temp_file"
  then
    git commit --file="$temp_file"
  fi
  rm -f "$temp_file"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  commit_with_message "$@"
fi
