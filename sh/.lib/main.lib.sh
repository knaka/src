#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_997bcd2-false}" && return 0; sourced_997bcd2=true

type before_source >/dev/null 2>&1 || . ./boot.lib.sh
before_source ./sub
. ./sub/sub.lib.sh
after_source

x868cb14() {
  echo f209986 main lib
}
