#!/usr/bin/env bash
set -- _98dc8d3 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./sleepnow.direct.bash
popd >/dev/null || exit

is_lid_closed() {
  ioreg -r -k AppleClamshellState -d 1 | grep -qE '"AppleClamshellState" = Yes'
}

sleep_if_lid_stays_closed() {
  export PATH="/usr/sbin:$PATH"
  local start
  start="$(date +%s)"
  while test $(($(date +%s) - start)) -lt 320
  do
    is_lid_closed || return 0
    sleep 20
  done
  is_lid_closed || return 0
  sleepnow "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  try_flock "$0" || exit 0
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 sleep_if_lid_stays_closed "$@"
fi
