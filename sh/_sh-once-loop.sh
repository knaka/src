#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_9f061bd-false}" && return 0; sourced_9f061bd=true

f() {
  echo initialization
  while :
  do
    echo foo
    if true
    then
      break
    fi
    echo bar
    break
  done
  echo finalization
}

f