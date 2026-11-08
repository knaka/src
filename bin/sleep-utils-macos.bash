#!/usr/bin/env bash
set -- _BIN_SLEEP_UTILS_MACOS_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Functions to get the conditions for deciding whether a Mac should sleep, and to put the system or display to sleep according to them. When executed directly, this script prints the current conditions and checks that the items they depend on still exist.

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./sleepnow.direct.bash
popd >/dev/null || exit

if ! is_macos
then
  echo "This script does not work on platforms other than macOS." >&2
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
  caffeinate -i -t 5 &
  local sleep_probe_pid=$!
  # -d: Create an assertion to prevent the display from sleeping.
  caffeinate -d -t 5 &
  # Wait for caffeinate to create its assertions.
  sleep 1
  local display_sleep_probe_pid=$!
  local i=0
  # The audio assertion may take longer to appear the first time, probably while the audio output starts up, so wait for it until shortly before the probes end.
  while test "$(audio_assertions | wc -l || true)" -le "$audio_count" -a "$i" -lt 20
  do
    sleep 0.1
    i=$((i + 1))
  done
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

# ==========================================================================
#region The following functions are expected to be called from cron at short intervals.

say() {
  # local voice="Daniel"
  local voice="Karen"
  # local voice="Samantha"
  command say --rate=120 --voice="$voice" "$1" || :
}

# Put the display to sleep when the user has been idle for 3 minutes, or 10 minutes on the charger, unless a process is preventing display sleep.
displaysleep_if_user_stays_idle() {
  local idle_limit_sec=$((3 * 60))
  is_charger_connected && idle_limit_sec=$((10 * 60))
  user_idle_seconds_ || return
  # This runs every minute, so the display is put to sleep only once when the idle time crosses the limit.
  test "$RESULT" -ge "$idle_limit_sec" -a "$RESULT" -lt $((idle_limit_sec + 60)) || return 0
  is_display_sleep_prevented && return 0
  sleepnow display
}

# Put the system to sleep when the user has been idle for 10 minutes, or 60 minutes on the charger, unless a process is preventing sleep or an SSH session is active.
sleep_if_user_stays_idle() {
  local idle_limit_sec=$((10 * 60))
  is_charger_connected && idle_limit_sec=$((60 * 60))
  # Sleep sooner even on the charger during the night, from 1:00 to 5:00.
  case "$(date +%H)" in
    (01|02|03|04) idle_limit_sec=$((10 * 60));;
  esac
  user_idle_seconds_ || return
  test "$RESULT" -lt "$idle_limit_sec" && return 0
  # Waking up may not reset the idle time, so do not put the system back to sleep right after that.
  seconds_since_wake_ || return
  test "$RESULT" -lt "$idle_limit_sec" && return 0
  is_sleep_prevented && return 0
  has_ssh_session && return 0
  say "No activity detected. Going to sleep now."
  sleep 1
  sleepnow "$@"
}

# Put the system to sleep if the lid stays closed for 5 minutes, announcing it by voice beforehand. Return as soon as the lid is found open.
sleep_if_lid_stays_closed() {
  local rest=$((5 * 60))
  local interval=20
  while test "$rest" -gt 0
  do
    is_lid_closed || return 0
    is_sleep_prevented && return 0
    case "$rest" in
      (180) say "Checkpoint 1. Going to sleep in 3 minutes. Checkpoint 1." &;;
      (60) say "Checkpoint 2. Going to sleep in 1 minute. Checkpoint 2." &;;
    esac
    sleep "$interval"
    rest=$((rest - interval))
  done
  is_lid_closed || return 0
  is_sleep_prevented && return 0
  say "Checkpoint 3. Lid closed. Going to sleep now. Checkpoint 3."
  sleep 1
  sleepnow "$@"
}

# Put the display to sleep and warn by voice if the system is still awake 6 minutes after the lid was found closed. Do not warn while audio is playing.
warn_awake_if_lid_stays_closed() {
  is_lid_closed || return 0
  is_audio_playing && return 0
  # Wait until sleep-if-lid-stays-closed, which runs every minute, should have put the system to sleep.
  sleep $((6 * 60))
  is_lid_closed || return 0
  sleepnow display
  is_audio_playing && return 0
  say "Checkpoint 4. Still awake with the lid closed. Checkpoint 4."
}

#endregion

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 sleep_conditions "$@"
fi
