#!/usr/bin/env bash
set -- _2b4ffa2 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./reset-system-settings.bash
popd >/dev/null || exit

show_usage_5ccb7a0() { cat <<EOF
Put the system to sleep in the specified mode. If the mode is omitted, the currently set mode is used.

Usage: $0 [display|suspend|hybrid|hibernate]
EOF
}

sleepnow() {
  local start
  start="$(date +%s)"
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
        (hibernate|disk)
          pmset -a hibernatemode 25
          ;;
        (*)
          echo Unknown mode: "$mode" >&2
          show_usage_5ccb7a0
          return 1
          ;;
      esac
      pmset -a disablesleep 0
      pmset sleepnow
      while test $(($(date +%s) - start)) -lt 5
      do
        sleep 1
      done
      reset_macos_power_settings
    fi
  fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 sleepnow "$@"
fi
