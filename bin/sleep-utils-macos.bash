#!/usr/bin/env bash
set -- _BIN_SLEEP_UTILS_MACOS_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Functions to get the conditions for deciding whether a Mac should sleep, and to put the system or display to sleep according to them. When executed directly, this script prints the current conditions and checks that the items they depend on still exist.

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./sleepnow.direct.bash
. ../.lib/time.sh
popd >/dev/null || exit

if ! is_macos
then
  echo "This script does not work on platforms other than macOS." >&2
  exit 1
fi

if test "$EUID" -ne 0 && ! sudo -k -n /usr/bin/pmset -g >/dev/null 2>&1
then
  echo "pmset cannot be run with sudo without a password. Run reset-system-settings first." >&2
  exit 1
fi

pmset() {
  if test "$EUID" -ne 0
  then
    sudo /usr/bin/pmset "$@"
  else
    /usr/bin/pmset "$@"
  fi
}

# For ioreg(8)
prepend_path \
  /usr/sbin \
  /usr/local/bin \
  /opt/homebrew/bin \
  #nop

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

# Check if the system is in DarkWake, where it is running without Graphics, such as during a maintenance wake. Return false if the capabilities are not found.
is_dark_wake() {
  pmset -g systemstate | grep '^Current System Capabilities are:' | grep_quiet -v ' Graphics'
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
  pmset -g systemstate | grep_quiet '^Current System Capabilities are:' \
    || fail_check_6e2b4d1 "The system capabilities are not found in pmset."
  test -z "${SSH_CONNECTION-}" || has_ssh_session \
    || fail_check_6e2b4d1 "No SSH server process is found in this SSH session."

  local audio_count
  audio_count="$(audio_assertions | wc -l || true)"
  # The assertion is held even with zero volume, so this is silent.
  afplay -v 0 /System/Library/Sounds/Funk.aiff &
  # Hold an assertion preventing idle sleep until killed after the checks, with a timeout as a safeguard, and keep the PID to find the assertion among those of other processes.
  # -i: Create an assertion to prevent the system from idle sleeping.
  caffeinate -i -t 10 &
  local sleep_probe_pid=$!
  # -d: Create an assertion to prevent the display from sleeping.
  caffeinate -d -t 10 &
  local display_sleep_probe_pid=$!
  # Wait for caffeinate to create its assertions.
  sleep 1
  local i=0
  # The audio assertion may take longer to appear the first time, probably while the audio output starts up, so wait for it for up to 2 more seconds.
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
  kill "$sleep_probe_pid" "$display_sleep_probe_pid"
  wait 2>/dev/null
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

  if is_dark_wake
  then
    echo "The system is in DarkWake." >&2
  else
    echo "The system is not in DarkWake." >&2
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
#region Put the system to sleep in the specified mode.

show_sleepnow_usage() { cat <<EOF
Put the system to sleep in the specified mode. If the mode is omitted, the currently set mode is used.

Usage: $0 [display|suspend|hybrid|hibernate]
EOF
}

restore_wifi_98761f3=false
restore_bt_f0de03b=false

restore_disablesleep_2db9e97() {
  pmset -a disablesleep 1
  "$restore_wifi_98761f3" && networksetup -setairportpower en0 on
  # blueutil -p 1
  if "$restore_bt_f0de03b" && shortcuts list | grep_quiet -x FluToothOn
  then
    shortcuts run FluToothOn
  fi
}

# Put the display or the system to sleep in the specified mode.
# To keep the system from waking up during sleep, Wi-Fi and Bluetooth are turned off before sleeping and turned back on after waking up, since a Bluetooth incoming connection or HID activity triggers a full wake. reset_macos_power_settings in reset-system-settings.bash also disables Power Nap, Wake on LAN (womp), TCP keepalive, ttyskeepawake, network over sleep, scheduled power events, and Bluetooth remote wake.
# The remaining DarkWakes are tolerated, since they last from a few seconds to about 45 seconds without Graphics and the system goes back to sleep by itself: maintenance wakes by PowerUIAgent for Optimized Battery Charging (com.apple.obc) every 15 minutes, only on the charger; CSPNEvaluation (Smart Power Nap) by powerd every hour, which can only be disabled with an undocumented feature flag; user-invisible alarms such as calendar travel time updates; and occasional wakes by the AOP.
sleepnow() {
  sleep_log "Calling ${FUNCNAME[0]}"
  trap_terminating_signals
  local mode
  mode="${1-}"
  if is_macos
  then
    if test -t 2
    then
      echo Entering sleep... >&2
    fi
    # The system does not enter sleep unless we wait for the key pressed to run this command to be released.
    sleep 1
    if test "$mode" = display
    then
      pmset displaysleepnow
    else
      case "$mode" in
        ("")
          ;;
        (suspend|memory)
          pmset -a hibernatemode 0
          ;;
        (hybrid|both)
          pmset -a hibernatemode 3
          ;;
        (hibernate|disk|storage)
          pmset -a hibernatemode 25
          ;;
        (*)
          echo Unknown mode: "$mode" >&2
          show_sleepnow_usage
          return 1
          ;;
      esac
      pmset displaysleepnow
      local sleeptime
      sleeptime="$(sysctl -n kern.sleeptime)"
      # Register the handler before turning anything off, so that whatever has been turned off is restored even if this fails partway. It restores only what the flags mark.
      add_exit_handler restore_disablesleep_2db9e97
      local i
      if networksetup -getairportpower en0 | grep_quiet ': On$'
      then
        networksetup -setairportpower en0 off
        restore_wifi_98761f3=true
      fi
      # blueutil -p 0 is aborted by TCC when run from Karabiner-Elements, so turn Bluetooth off with a shortcut instead, since Shortcuts has access to Bluetooth.
      if system_profiler SPBluetoothDataType | grep_quiet 'State: On' \
        && shortcuts list | grep_quiet -x FluToothOff
      then
        shortcuts run FluToothOff
        restore_bt_f0de03b=true
        i=0
        while system_profiler SPBluetoothDataType | grep_quiet 'State: On' && test "$i" -lt 10
        do
          sleep 1
          i=$((i + 1))
        done
        # The system does not sleep if put to sleep right after Bluetooth is reported off, for an unknown reason. It is not the assertion of bluetoothd, which is released immediately, so just wait for a while.
        sleep 5
      fi
      pmset -a disablesleep 0
      sleep_log "CP10"
      pmset sleepnow &>/dev/null
      # Restore the settings after the system has actually slept, since restoring `disablesleep` too early aborts the sleep and leaves the system in DarkWake. Give up after a while in case the sleep is canceled.
      i=0
      while test "$(sysctl -n kern.sleeptime)" = "$sleeptime" -a "$i" -lt 60
      do
        sleep 1
        i=$((i + 1))
      done
      # Do not restore the settings during DarkWake, such as one for maintenance, since the system cannot go back to sleep from it while `disablesleep` is set.
      while is_dark_wake
      do
        sleep 10
      done
    fi
  fi
}

#endregion

# ==========================================================================
#region The following functions are expected to be called from cron at short intervals.

readonly logfile=/tmp/sleep.log

say() {
  # local voice="Daniel"
  local voice="Karen"
  # local voice="Samantha"
  command say --rate=120 --voice="$voice" "$1" || :
}

ja_say() {
  local voice="Kyoko"
  command say --voice="$voice" "$1" || :
}

# shellcheck disable=SC2317
sleep_log() {
  return 0
  local dark_wake=false
  is_dark_wake && dark_wake=true
  local sleep_prevented=false
  is_sleep_prevented && sleep_prevented=true
  local lid_closed=false
  is_lid_closed && lid_closed=true
  echo "$(date_iso): $* (lid_closed: $lid_closed, dark_wake: $dark_wake, sleep_prevented: $sleep_prevented)" >>"$logfile"
}

# Put the display to sleep when the user has been idle for 3 minutes, or 10 minutes on the charger, unless a process is preventing display sleep.
displaysleep_if_user_stays_idle() {
  sleep_log "Calling ${FUNCNAME[0]}"
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
  sleep_log "Calling ${FUNCNAME[0]}"
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
  sleep_log "CP0"
  say "Checkpoint 0. No activity detected. Going to sleep now. Checkpoint 0."
  sleep 1
  sleepnow "$@"
}

# Put the system to sleep if the lid stays closed for 5 minutes, announcing it by voice beforehand. Return as soon as the lid is found open.
sleep_if_lid_stays_closed() {
  sleep_log "Calling ${FUNCNAME[0]}"
  local rest=$((5 * 60))
  local interval=20
  while test "$rest" -gt 0
  do
    is_lid_closed || return 0
    is_sleep_prevented && return 0
    is_dark_wake && return 0
    case "$rest" in
      (180)
        sleep_log "CP1"
        say "Checkpoint 1. Going to sleep in 3 minutes. Checkpoint 1." &
        ;;
      (60)
        sleep_log "CP2"
        say "Checkpoint 2. Going to sleep in 1 minute. Checkpoint 2." &
        ;;
    esac
    sleep "$interval"
    rest=$((rest - interval))
  done
  is_lid_closed || return 0
  is_sleep_prevented && return 0
  is_dark_wake && return 0
  sleep_log "CP3"
  say "Checkpoint 3. Lid closed. Going to sleep now. Checkpoint 3."
  sleep 1
  sleepnow "$@"
}

# Put the display to sleep and warn by voice if the system is still awake 6 minutes after the lid was found closed. Do not warn while audio is playing.
warn_awake_if_lid_stays_closed() {
  sleep_log "Calling ${FUNCNAME[0]}"
  is_lid_closed || return 0
  is_audio_playing && return 0
  is_dark_wake && return 0
  # Wait until sleep-if-lid-stays-closed, which runs every minute, should have put the system to sleep.
  sleep $((6 * 60))
  is_lid_closed || return 0
  sleepnow display
  is_audio_playing && return 0
  is_dark_wake && return 0
  sleep_log "CP4"
  say "Checkpoint 4. Still awake with the lid closed. Checkpoint 4."
}

#endregion

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 sleep_conditions "$@"
fi
