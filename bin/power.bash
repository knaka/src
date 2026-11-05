#!/usr/bin/env bash
set -- _9057fa1 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# For ioreg(8)
prepend_path /usr/sbin

is_lid_closed() {
  ioreg -r -k AppleClamshellState -d 1 | grep -qE '"AppleClamshellState" = Yes' || test $? -eq "$RC_SIGPIPE"
}

is_audio_playing() {
  pmset -g assertions | grep -q 'coreaudiod.*preventuseridlesleep' || test $? -eq "$RC_SIGPIPE"
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
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 power "$@"
fi
