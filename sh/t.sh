#!/bin/sh
set -o nounset -o errexit

test "${guard_c6d16e2+set}" = set && return 0; guard_c6d16e2=x

if test -d "c:/" && test -r "./task.cmd"
then
  exec ./task.cmd "$@"
fi
if type ./task >/dev/null 2>&1
then
  exec ./task "$@"
fi
if test -d ./tasks
then
  for sh in /bin/dash /bin/bash
  do
    if command -v "$sh" >/dev/null 2>&1
    then
      export ARG0="$0"
      export ARG0BASE="$(basename "$0")"s
      export PROJECT_DIR="$PWD"
      export TASKS_DIR="$PWD/tasks"
      exec "$sh" ./tasks/task.sh "$@"
    fi
  done
elif test -r "package.json"
then
  npm run "$@"
fi
exit 1
