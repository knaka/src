#!/usr/bin/env bash
set -- _390c5b7 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/percent-encode.sh
popd >/dev/null || exit

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 percent_encode "$@"
fi
