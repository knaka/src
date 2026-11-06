#!/usr/bin/env bash
set -- _9057fa1 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Functions to get the conditions for deciding whether a Mac should sleep. When executed directly, this script prints the current conditions and checks that the items they depend on still exist.

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

audio_assertions() {
  pmset -g assertions | grep 'coreaudiod.*preventuseridlesleep'
}

is_audio_playing() {
  audio_assertions >/dev/null
}

is_charger_connected() {
  pmset -g ps | grep_quiet "drawing from 'AC Power'"
}

# List the assertions preventing the system from sleeping, except for powerd, which holds one while `disablesleep` is set.
sleep_assertions() {
  pmset -g assertions | grep -v '(powerd)' | grep -E '^ *pid [0-9]+\(.*\): .* (PreventUserIdleSystemSleep|PreventSystemSleep|NoIdleSleepAssertion) named:'
}

is_sleep_prevented() {
  sleep_assertions >/dev/null
}

# List the assertions preventing the display from sleeping, such as during video playback.
display_sleep_assertions() {
  pmset -g assertions | grep -v '(powerd)' | grep -E '^ *pid [0-9]+\(.*\): .* (PreventUserIdleDisplaySleep|NoDisplaySleepAssertion) named:'
}

is_display_sleep_prevented() {
  display_sleep_assertions >/dev/null
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

fail_check_6e2b4d1() {
  echo "Check failed: $*" >&2
  failed=true
}

# Check that the items which the functions above depend on still exist, since they may change with an OS update. Other processes may already hold assertions, so see what the probes add rather than whether the functions return true.
check_sleep_conditions_6e2b4d1() {
  echo "Checking the sleep conditions. This takes a few seconds..." >&2
  ioreg -r -k AppleClamshellState -d 1 | grep_quiet -E '"AppleClamshellState" = (Yes|No)' \
    || fail_check_6e2b4d1 "AppleClamshellState is not found in ioreg."
  pmset -g ps | grep_quiet -E "drawing from '(AC|Battery|UPS) Power'" \
    || fail_check_6e2b4d1 "The power source is not found in pmset."
  pmset -g ps | grep_quiet -E 'InternalBattery.*[^0-9][0-9]+%;' \
    || fail_check_6e2b4d1 "The battery percentage is not found in pmset."
  # CGSSessionScreenIsLocked seems to exist only while the screen is locked, so check the console user information that it belongs to instead.
  ioreg -n Root -d 1 | grep_quiet '"kCGSSessionOnConsoleKey"=' \
    || fail_check_6e2b4d1 "The console user information is not found in ioreg."
  test -z "${SSH_CONNECTION-}" || has_ssh_session \
    || fail_check_6e2b4d1 "No SSH server process is found in this SSH session."

  local audio_count
  audio_count="$(audio_assertions | wc -l || true)"
  # The assertion is held even with zero volume, so this is silent.
  afplay -v 0 /System/Library/Sounds/Funk.aiff &
  # Hold an assertion preventing idle sleep for 3 seconds, and keep the PID to find the assertion among those of other processes.
  # -i: Create an assertion to prevent the system from idle sleeping.
  caffeinate -i -t 3 &
  local sleep_probe_pid=$!
  # -d: Create an assertion to prevent the display from sleeping.
  caffeinate -d -t 3 &
  local display_sleep_probe_pid=$!
  sleep 1
  test "$(audio_assertions | wc -l || true)" -gt "$audio_count" \
    || fail_check_6e2b4d1 "Playing a sound does not add an audio assertion."
  sleep_assertions | grep_quiet "^ *pid $sleep_probe_pid(" \
    || fail_check_6e2b4d1 "caffeinate -i is not detected as preventing sleep."
  display_sleep_assertions | grep_quiet "^ *pid $display_sleep_probe_pid(" \
    || fail_check_6e2b4d1 "caffeinate -d is not detected as preventing display sleep."
  wait
  echo "Finished checking the sleep conditions." >&2
}

sleep_conditions() {
  local failed=false

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

  # if is_display_asleep_not_recommended
  # then
  #   echo "The display is asleep." >&2
  # else
  #   echo "The display is awake." >&2
  # fi

  if is_screen_locked
  then
    echo "The screen is locked." >&2
  else
    echo "The screen is not locked." >&2
  fi

  if user_idle_seconds_
  then
    echo "The user has been idle for $RESULT seconds." >&2
  else
    fail_check_6e2b4d1 "HIDIdleTime is not found in ioreg."
  fi

  if seconds_since_wake_
  then
    echo "The system woke $RESULT seconds ago." >&2
  else
    fail_check_6e2b4d1 "kern.waketime cannot be parsed."
  fi

  battery_percent_
  echo "The battery is at $RESULT%." >&2
  check_sleep_conditions_6e2b4d1
  test "$failed" = false
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 sleep_conditions "$@"
fi
