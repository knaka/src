#!/bin/sh
test "${guard_8986b2e+set}" = set && return 0; guard_8986b2e=x
set -o nounset -o errexit

. ./task.sh

ln -sf target "$TEMP_DIR"/symlink
if ! test -L "$TEMP_DIR"/symlink
then
  echo "Failed to create symlink." >&2
  if is_windows
  then
    echo "To enable symlink creation on Windows, enable Developer Mode or run as Administrator." >&2
  fi
  exit 1
fi
