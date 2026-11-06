#!/usr/bin/env bash
set -- _89962c5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

null_value() {
  local -a array=(foo bar baz)
  echo fafa3f8 ${#array[@]}
  array+=(${not_defined+"$not_defined"})
  echo f226958 ${#array[@]}
  local defined=qux
  array+=("${defined-}")
  echo c1f8e7b ${#array[@]}
  array+=("")
  echo a72f80e ${#array[@]}
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 null_value "$@"
fi
