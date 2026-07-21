#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ c40b851 && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
shift 2
set -- _LIBDIR . "$@"
. ./test.sh
shift 2
cd "$1" || exit; shift

temp_path_a4f366e=

exit_handler_6cff844() {
  test -z "$temp_path_a4f366e" && exit 1
  echo true >"$temp_path_a4f366e"
}

test_exit_behavior() {
  skip_if is_bbwin

  temp_path_a4f366e="$(mktemp)"
  local signal
  # “When job control is not in effect, asynchronous commands ignore SIGINT and SIGQUIT in addition to these inherited handlers.”
  # — Signals (Bash Reference Manual) https://doc.guix.gnu.org/bash/latest/en/html_node/Signals.html
  # for signal in HUP INT TERM PIPE ALRM USR1 USR2
  for signal in HUP TERM PIPE ALRM USR1 USR2
  do
    (
      rm -f "$temp_path_a4f366e"
      echo false >"$temp_path_a4f366e"
      # “In a strictly POSIX shell, the EXIT trap is evaluated before the shell exits due to executing exit or due to executing the last command in a script. It is not executed if the shell exits due to a signal.”
      # — shell - EXIT Trap with POSIX - Unix & Linux Stack Exchange https://unix.stackexchange.com/questions/520035/exit-trap-with-posix
      is_bash_bin || trap exit HUP INT TERM PIPE ALRM USR1 USR2
      trap exit_handler_6cff844 EXIT
      sleep 100 &
      wait $!
      exit 123
    ) &
    local pid=$!
    sleep 0.5
    kill -"$signal" "$pid"
    local rc=0
    wait "$pid" || rc=$?
    echo "RC: $rc" >&2
    local sig_rc=
    eval sig_rc=\$RC_SIG$signal
    assert_eq -m"SIG$signal" "$rc" "$sig_rc"
    assert_eq "$(cat "$temp_path_a4f366e")" true
  done
  rm -f "$temp_path_a4f366e"
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ test-exit-behavior
then
  set -o nounset -o errexit
  test_exit_behavior "$@"
fi
