#!/usr/bin/env bash
set -- _BIN_WDIFF_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./git-wdiff.bash
popd >/dev/null || exit

wdiff() {
  tail_call git_wdiff --no-index "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 wdiff "$@"
fi
