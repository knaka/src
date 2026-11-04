#!/usr/bin/env bash
set -- _2b4ffa2 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./reset-system-settings.bash
popd >/dev/null || exit

sleepnow() {
  if is_macos
  then
    local start
    start="$(date +%s)"
    pmset -a disablesleep 0
    sleep 1
    pmset sleepnow &
    while test $(($(date +%s) - start)) -lt 5
    do
      sleep 1
    done
    reset_macos_power_settings
  fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 sleepnow "$@"
fi
