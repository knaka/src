#!/usr/bin/env bash
set -- _BIN_WARN_AWAKE_IF_LID_STAYS_CLOSED_DIRECT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./sleep-utils.bash
popd >/dev/null || exit

if test "$0" = "${BASH_SOURCE[0]}"
then
  try_flock "$0" || exit 0
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 warn_awake_if_lid_stays_closed "$@"
fi
