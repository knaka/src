#!/usr/bin/env bash
set -- _bbfb233 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

foo() {
  tail_exec /bin/echo Hello
}

x_59daf55() {
  foo # Does not exec(2).
  TAIL_DEPTH=$((TAIL_DEPTH+1)) foo # Does exec(2).
  echo Not reached. >&2
  exit 1
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 x_59daf55 "$@"
fi
