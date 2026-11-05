#!/usr/bin/env bash
set -- _2f9d6d5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

is_lid_closed() {
  ioreg -r -k AppleClamshellState -d 1 | grep -qE '"AppleClamshellState" = Yes'
}

is_audio_playing() {
  pmset -g assertions | grep -q 'coreaudiod.*preventuseridlesleep'
}

check_clamshell() {
  local voice="Samantha"
  export PATH="/usr/sbin:$PATH"
  is_lid_closed || return 0
  is_audio_playing && return 0
  # Wait until sleep-if-lid-stays-closed, run every minute, should have put the system to sleep.
  sleep 360
  is_lid_closed || return 0
  is_audio_playing && return 0
  say -v "$voice" "Not sleeping even though the lid is closed."
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  exec 9< "$0"
  perl -mFcntl=:flock -e "open(LOCK,'<&=9');exit(!flock(LOCK,LOCK_EX|LOCK_NB))" || exit 0
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 check_clamshell "$@"
fi
