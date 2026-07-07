#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_765fe7a-false}" && return 0; sourced_765fe7a=true

zless() {
  echo "FOO" "$@"
}

# This calls function.
# zless --help

# This call the external command, ofcourse.
# command zless --help

# This calls the external command also
# exec zless --help
