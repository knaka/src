# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_KILL_TEST_SH && return # shpp:source_guard

on_exit() {
  echo 2bbea32 Killing
  /bin/kill -TERM 0
}

foo() {
  local child_pid_file
  child_pid_file="$(mktemp)"
  set -m
  (
    # trap : TERM
    trap on_exit EXIT
    sleep 1234 &
    echo $! >"$child_pid_file"
    wait || :
    echo Done. >&2
  ) &
  local harness_pid="$!"
  set +m
  sleep 0.1

  # Poll until child_pid_file appears.
  local i=0
  while ! test -s "$child_pid_file"
  do
    i=$((i + 1))
    sleep 0.1
  done
  local child_pid
  child_pid="$(cat "$child_pid_file")"
  echo "Child PID: $child_pid" 

  kill -TERM "$harness_pid"
  sleep 0.5

  if kill -0 "$child_pid"
  then
    echo b6b79fc
    return 1
  fi
  if kill -0 "$harness_pid"
  then
    echo 705d9df
    return 1
  fi
  echo 2557beb
}

set -o nounset -o errexit

if test "${1-}" != subshell
then
  foo
else
  # トップレベル以外での `set -m` の挙動は未定義で、Bash だと都度正しく動くが、Dash だと setpgid しない。
  # dash の job control 実装は「tcsetpgrp() で自分がその端末のフォアグラウンドプロセスグループになれるか」を前提にしていて、既にフォークされたサブシェル(セッションリーダーでも既存のフォアグラウンドグループでもないプロセス)からそれを試みると失敗し、フォールバックとして「グループ分け自体を諦める」実装になっている模様…？
  ( foo )
fi

echo Done all
