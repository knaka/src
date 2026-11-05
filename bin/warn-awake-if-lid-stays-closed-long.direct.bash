#!/usr/bin/env bash
set -- _2f9d6d5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./power.bash
. ./sleepnow.direct.bash
popd >/dev/null || exit

warn_awake_if_lid_stays_closed_long() {
  local voice="Samantha"
  is_lid_closed || return 0
  is_audio_playing && return 0
  # Wait until sleep-if-lid-stays-closed, run every minute, should have put the system to sleep.
  sleep 360
  is_lid_closed || return 0
  sleepnow display
  is_audio_playing && return 0
  say -v "$voice" "Not sleeping even though the lid is closed."
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  try_flock "$0" || exit 0
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 warn_awake_if_lid_stays_closed_long "$@"
fi
