# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 1419b3b && return 0

# Worker queue.

{ pushd "${BASH_SOURCE[0]%/*}" || pushd "${BASH_SOURCE[0]%\\*}" || pushd .; } >/dev/null 2>&1
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
popd >/dev/null || exit 1

: "${worker_queue_dir_24f4ecb-}"

run_worker() {
  local base log_file
  base="$(echo "$*" | sed -Ee 's/[^[:alnum:]]/_/g')"
  log_file="$(mktemp "$worker_queue_dir_24f4ecb"/"$base.log.XXXXX")"
  touch "$log_file"
  local disable_monitor=false
  [[ $- != *m* ]] && set -m && disable_monitor=true
  "$@" </dev/null >"$log_file" 2>&1 &
  local pid="$!"
  # `disown` is Bash specific.
  disown %+
  "$disable_monitor" && set +m
  echo "$pid" >>"$worker_queue_dir_24f4ecb"/wids
  echo "$pid"
  echo "$log_file" >"$worker_queue_dir_24f4ecb"/"log-file.$pid"
  echo "$@" >"$TEMP_DIR"/args."$pid"
}

tail_worker() (
  if test $# -eq 0
  then
    # shellcheck disable=SC2046
    set -- $(cat "$worker_queue_dir_24f4ecb"/wids)
  fi
  declare -a log_files
  for wid in "$@"
  do
    # shellcheck disable=SC2030
    log_files+=("$(cat "$worker_queue_dir_24f4ecb"/"log-file.$wid")")
  done
  trap : INT
  set -m
  tail -f "${log_files[@]}" || :
)

log_worker() {
  if test $# -eq 0
  then
    # shellcheck disable=SC2046
    set -- $(cat "$worker_queue_dir_24f4ecb"/wids)
  fi
  declare -a log_files
  for wid in "$@"
  do
    # shellcheck disable=SC2031
    log_files+=("$(cat "$worker_queue_dir_24f4ecb"/"log-file.$wid")")
  done
  cat "${log_files[@]}" || :
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
    kill -TERM "$wid" >/dev/null 2>&1 || :
  done
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
  stop_worker --timeout-sec=10 $(cat "$worker_queue_dir_24f4ecb"/wids)
}

init_worker_queue() {
  first_call b03ec06 || return 0
  init_temp
  worker_queue_dir_24f4ecb="$TEMP_DIR/worker-queue"
  mkdir -p "$worker_queue_dir_24f4ecb"
  touch "$worker_queue_dir_24f4ecb"/wids
  prepend_cleanup cleanup_worker_queue
}
