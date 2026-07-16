#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ LIB_WORKER_SH && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit; shift

: "${worker_queue_dir_60742ac-}"

run_worker() {
  local base log_file
  base="$(echo "$*" | sed -Ee 's/[^[:alnum:]]/_/g')"
  log_file="$(mktemp "$worker_queue_dir_60742ac"/"$base.log.XXXXX")"
  touch "$log_file"
  local pid
  if is_bash_bin
  then
    # Bash provides rich job control feature even on MSYS2.
    local disable_monitor=false
    case "$-" in
      (*m*) ;;
      (*)
        set -m
        disable_monitor=true
        ;;
    esac
    # Run the background job and detach from the shell's job table so this
    # worker (though in its own process group via `set -m`) isn't reaped/awaited
    # by an unrelated bare `wait`/`jobs` the caller (who sourced this library)
    # might run later.
    "$@" </dev/null >"$log_file" 2>&1 &
    pid="$!"
    # shellcheck disable=SC3044
    disown %+
    "$disable_monitor" && set +m
  elif is_linux
  then
    # Run the backgrounding itself inside a subshell (rather than plain `setsid
    # ... &` here) so the worker's direct parent is this subshell, which exits
    # immediately after echoing its pid. That orphans the worker right away,
    # regardless of how the caller happens to invoke `run_worker` (e.g. even
    # without wrapping the call in `$(...)`), so it can never be swept up by an
    # unrelated bare `wait`/`jobs` in the caller's shell. (POSIX sh has no
    # `disown` to do this explicitly.)
    pid="$(setsid "$@" </dev/null >"$log_file" 2>&1 & echo $!)"
  elif is_macos
  then
    # No `setsid(1)` command on macOS, so call POSIX::setsid() from Perl
    # instead, right before exec'ing into "$@" (no extra fork: like `setsid(1)`
    # on Linux, the Perl process itself becomes the worker via exec, so its pid
    # stays the worker's pid). Wrapped in the same detaching subshell as the
    # Linux branch above, for the same reason.
    pid="$(perl -e 'use POSIX "setsid"; setsid(); exec @ARGV' "$@" </dev/null >"$log_file" 2>&1 & echo $!)"
  fi
  echo "$pid" >>"$worker_queue_dir_60742ac"/wids
  echo "$pid"
  echo "$log_file" >"$worker_queue_dir_60742ac"/"log-file.$pid"
  echo "$@" >"$TEMP_DIR"/args."$pid"
}

tail_worker() (
  if test $# -eq 0
  then
    # shellcheck disable=SC2046
    set -- $(cat "$worker_queue_dir_60742ac"/wids)
  fi
  local wid
  local log_file
  for wid in "$@"
  do
    set -- "$@" "$(cat "$worker_queue_dir_60742ac"/"log-file.$wid")"
    shift
  done
  trap : INT
  tail -f "$@" || :
)

log_worker() {
  if test $# -eq 0
  then
    # shellcheck disable=SC2046
    set -- $(cat "$worker_queue_dir_60742ac"/wids)
  fi
  local wid
  local log_file
  for wid in "$@"
  do
    set -- "$@" "$(cat "$worker_queue_dir_60742ac"/"log-file.$wid")"
    shift
  done
  trap : INT
  tail -f "$@" || :
  cat "$@"
}

stop_worker() {
  local timeout_sec=0
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (timeout-sec) timeout_sec="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local wid
  for wid in "$@"
  do
    # Signal the whole process group (run_worker starts each job in its own
    # group via `set -m` or setsid(1)), so any children the worker itself
    # backgrounded get terminated too, not just the worker's top-level process.
    kill -TERM -"$wid" >/dev/null 2>&1 || :
  done
  if test "$timeout_sec" -eq 0
  then
    return 0
  fi
  sleep 0.1
  for wid in "$@"
  do
    while is_worker_alive "$wid"
    do
      if test "$timeout_sec" -eq 0
      then
        echo "Failed to stop worker: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
        return 1
      fi
      sleep 1
      timeout_sec=$((timeout_sec - 1))
    done
    echo "Stopped worker: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
  done
  return 0
}

pid_of_worker() {
  local wid="$1"
  echo "$wid"
}

wait_worker_start() {
  local timeout_sec=3
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (timeout-sec) timeout_sec="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local wid
  for wid in "$@"
  do
    while :
    do
      is_worker_alive "$wid" && break
      if test "$timeout_sec" -eq 0
      then
        echo "Timedout to wait start: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
        return 1
      fi
      sleep 1
      timeout_sec=$((timeout_sec - 1))
    done
  done
}

is_worker_alive() {
  local wid
  for wid in "$@"
  do
    kill -0 "$wid" >/dev/null 2>&1 || return 1
  done
}

wait_worker() {
  local timeout_sec=3
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (timeout-sec) timeout_sec="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local wid
  for wid in "$@"
  do
    while :
    do
      is_worker_alive "$wid" || break
      if test "$timeout_sec" -eq 0
      then
        echo "Timedout to wait: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
        return 1
      fi
      sleep 1
      timeout_sec=$((timeout_sec - 1))
    done
  done
}

cleanup_worker_queue() {
  # shellcheck disable=SC2046
  stop_worker --timeout-sec=10 $(cat "$worker_queue_dir_60742ac"/wids)
  rm -fr "$worker_queue_dir_60742ac"
}

init_worker_queue() {
  first_call b03ec06 || return 0
  if is_bash_bin || is_linux || is_macos
  then
    :
  else
    echo "Not supported (df631f1)." >&2
    return 1
  fi
  init_temp
  worker_queue_dir_60742ac="$TEMP_DIR/worker-queue"
  mkdir -p "$worker_queue_dir_60742ac"
  touch "$worker_queue_dir_60742ac"/wids
  prepend_cleanup cleanup_worker_queue
}
