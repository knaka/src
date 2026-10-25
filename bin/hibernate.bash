#!/usr/bin/env bash
set -- _88e97b1 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./reset-system-settings.bash
popd >/dev/null || exit

ensure_root() {
  if test "$EUID" -ne 0
  then
    echo "This script requires root privileges. Re-running with sudo..."
    exec sudo bash "$0" "$@"
  fi
}

hibernate_macos() {
  pmset -a hibernatemode 25
  local start
  start="$(date +%s)"
  # Wait until the key pressed to run this command is released, so that releasing it doesn't wake the system up immediately.
  sleep 1
  pmset sleepnow
  # `pmset sleepnow` returns before the system actually sleeps, and hibernatemode is read when it goes to sleep, so don't restore it right away. The wall clock keeps running during sleep, so this loop ends right after waking up.
  while test $(($(date +%s) - start)) -lt 30
  do
    sleep 1
  done
  reset_macos_power_settings
}

hibernate() {
  if is_macos
  then
    ensure_root
    hibernate_macos
  elif is_windows
  then
    MSYS2_ARG_CONV_EXCL='*' shutdown /h
  elif is_linux
  then
    systemctl hibernate
  else
    echo "Error (74f0e50)" >&2
    return 1
  fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 hibernate "$@"
fi
