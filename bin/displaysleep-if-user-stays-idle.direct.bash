#!/usr/bin/env bash
set -- _BIN_DISPLAYSLEEP_IF_USER_STAYS_IDLE_DIRECT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./sleep-utils-macos.bash
popd >/dev/null || exit

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 displaysleep_if_user_stays_idle "$@"
fi
