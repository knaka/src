#!/usr/bin/env bash
set -- _f41aa21 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./power.bash
. ./sleepnow.direct.bash
popd >/dev/null || exit

sleep_if_user_stays_idle() {
  local idle_limit=600
  is_charger_connected && idle_limit=3600
  user_idle_seconds_ || return
  test "$RESULT" -ge "$idle_limit" || return 0
  # Waking up may not reset the idle time, so do not put the system back to sleep right after that.
  seconds_since_wake_ || return
  test "$RESULT" -ge "$idle_limit" || return 0
  is_sleep_prevented && return 0
  has_ssh_session && return 0
  sleepnow "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  try_flock "$0" || exit 0
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 sleep_if_user_stays_idle "$@"
fi
