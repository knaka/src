#!/bin/sh
set -o nounset -o errexit

test "${guard_20b5636+set}" = set && return 0; guard_20b5636=-

. task.sh

subcmd_sqlite3() ( # Run Sqlite3.
  if is_windows
  then
    cmd_path="C:/Program Files/SQLite/SQLite3/sqlite3.exe"
    if ! type "$cmd_path" > /dev/null 2>&1
    then
      winget install -e --id SQLite.SQLite
      cmd_path=sqlite3
    fi
    "$cmd_path" "$@"
    return $?
  fi
  if ! type sqlite3 > /dev/null 2>&1
  then
    echo "Please install SQLite3." >&2
    exit 1
  fi
  sqlite3 "$@"
)