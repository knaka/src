#!/usr/bin/env bash
set -- _c0838a7 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

loop() {
  set -- foo bar baz
  local x
  for x
  do
    echo "$x"
  done

  set --
  test $# -eq 0
  local x
  for x
  do
    echo "$x"
  done

  local a=(aaa bbb)
  local x
  for x in ${a[@]+"${a[@]}"}
  do
    echo "$x"
  done
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 loop "$@"
fi
