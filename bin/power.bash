#!/usr/bin/env bash
set -- _9057fa1 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

if ! is_macos
then
  echo "This script does not work on platforms other than macOS yet." >&2
  exit 1
fi

# For ioreg(8)
prepend_path /usr/sbin

is_lid_closed() {
  ioreg -r -k AppleClamshellState -d 1 | grep_quiet -E '"AppleClamshellState" = Yes'
}

is_audio_playing() {
  pmset -g assertions | grep_quiet 'coreaudiod.*preventuseridlesleep'
}

is_charger_connected() {
  pmset -g ps | grep_quiet "drawing from 'AC Power'"
}

# Check if a process other than powerd, which holds an assertion while `disablesleep` is set, prevents the system from sleeping.
is_sleep_prevented() {
  pmset -g assertions | grep -v '(powerd)' | grep_quiet -E '^ *pid [0-9]+\(.*\): .* (PreventUserIdleSystemSleep|PreventSystemSleep|NoIdleSleepAssertion) named:'
}

# Check if a process prevents the display from sleeping, such as during video playback.
is_display_sleep_prevented() {
  pmset -g assertions | grep -v '(powerd)' | grep_quiet -E '^ *pid [0-9]+\(.*\): .* (PreventUserIdleDisplaySleep|NoDisplaySleepAssertion) named:'
}

# Check if a process serves an SSH connection, including one without a login session such as scp.
has_ssh_session() {
  ps -axo comm= | grep_quiet -E '(^|/)sshd(-session)?$'
}

# Check if the last display power event in the power management log is turning off. Not recommended, since reading the whole log is heavy and takes more than a second.
is_display_asleep_not_recommended() {
  pmset -g log | grep 'Display is turned' | tail -n 1 | grep -q 'turned off'
}

is_screen_locked() {
  ioreg -n Root -d 1 | grep_quiet '"CGSSessionScreenIsLocked"=Yes'
}

# Set $RESULT to the seconds elapsed since the last user input event.
user_idle_seconds_() {
  local idle_ns
  # HIDIdleTime is in nanoseconds.
  idle_ns="$(ioreg -r -k HIDIdleTime -d 1 | awk '/"HIDIdleTime"/ { print $NF }')"
  test -n "$idle_ns" || return 1
  set_ $((idle_ns / 1000000000))
}

# Set $RESULT to the seconds elapsed since the system last woke from sleep.
seconds_since_wake_() {
  local wake_time
  wake_time="$(sysctl -n kern.waketime | sed -n -e 's/^{ sec = \([0-9]*\),.*/\1/p')"
  test -n "$wake_time" || return 1
  set_ $(($(date +%s) - wake_time))
}

# Set $RESULT to the remaining battery percentage. Machines without a battery are regarded as 100.
battery_percent_() {
  local status
  status="$(pmset -g ps)" || return 1
  local percent
  percent="$(echo "$status" | sed -n -e '/InternalBattery/s/.*[^0-9]\([0-9]*\)%;.*/\1/p')"
  set_ "${percent:-100}"
}

power() {
  if is_lid_closed
  then
    echo "The lid is closed." >&2
  else
    echo "The lid is open." >&2
  fi
  if is_audio_playing
  then
    echo "Audio is playing." >&2
  else
    echo "Audio is not playing." >&2
  fi
  if is_charger_connected
  then
    echo "The charger is connected." >&2
  else
    echo "The charger is not connected." >&2
  fi
  if is_sleep_prevented
  then
    echo "A process is preventing sleep." >&2
  else
    echo "No process is preventing sleep." >&2
  fi
  if is_display_sleep_prevented
  then
    echo "A process is preventing display sleep." >&2
  else
    echo "No process is preventing display sleep." >&2
  fi
  if has_ssh_session
  then
    echo "An SSH session is active." >&2
  else
    echo "No SSH session is active." >&2
  fi
  if is_display_asleep_not_recommended
  then
    echo "The display is asleep." >&2
  else
    echo "The display is awake." >&2
  fi
  if is_screen_locked
  then
    echo "The screen is locked." >&2
  else
    echo "The screen is not locked." >&2
  fi
  user_idle_seconds_
  echo "The user has been idle for $RESULT seconds." >&2
  seconds_since_wake_
  echo "The system woke $RESULT seconds ago." >&2
  battery_percent_
  echo "The battery is at $RESULT%." >&2
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 power "$@"
fi
