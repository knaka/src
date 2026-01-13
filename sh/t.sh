#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4e43a4f-false}" && return 0; sourced_4e43a4f=true

root_dir=/
cmd_base=task
if test -d "c:/"
then
  root_dir="c:/"
  cmd_base=task.cmd
fi

dir=.
while :
do
  p="$(realpath "$dir")"
  test "$p" = "$root_dir" && exit 1
  test -x "$p"/"$cmd_base" && exec "$p"/"$cmd_base" "$@"
  dir=../"$dir"
done
