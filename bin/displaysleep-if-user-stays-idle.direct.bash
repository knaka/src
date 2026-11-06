#!/usr/bin/env bash
set -- _53f604e "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./sleep-conditions.bash
. ./sleepnow.direct.bash
popd >/dev/null || exit

displaysleep_if_user_stays_idle() {
  local idle_limit=180
  is_charger_connected && idle_limit=600
  user_idle_seconds_ || return
  # This runs every minute, so the display is put to sleep only once when the idle time crosses the limit.
  test "$RESULT" -ge "$idle_limit" -a "$RESULT" -lt $((idle_limit + 60)) || return 0
  is_display_sleep_prevented && return 0
  sleepnow display
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 displaysleep_if_user_stays_idle "$@"
fi
