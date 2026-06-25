# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ b0cdf45 && return 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./utils.lib.sh
popd >/dev/null || exit 1

# ==========================================================================
#region Worker queue

: "${worker_queue_dir_24f4ecb-}"

run_worker() {
  local base log_file
  base="$(echo "$*" | sed -Ee 's/[^[:alnum:]]/_/g')"
  log_file="$(mktemp "$worker_queue_dir_24f4ecb"/"$base.log.XXXXX")"
  touch "$log_file"
  local restore_m=false
  [[ $- != *m* ]] && restore_m=true
  set -m
  "$@" </dev/null >"$log_file" 2>&1 &
  local pid="$!"
  disown %+
  "$restore_m" && set +m
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
  local wid
  for wid in "$@"
  do
    kill -TERM "$wid"
  done
  sleep 0.1
  for wid in "$@"
  do
    while kill -0 "$wid" >/dev/null 2>&1
    do
      sleep 0.1
    done
    echo "Stopped worker: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
  done
  return 0
}

cleanup_worker_queue() {
  # shellcheck disable=SC2046
  stop_worker $(cat "$worker_queue_dir_24f4ecb"/wids)
}

init_worker_queue() {
  first_call b03ec06 || return 0
  init_temp
  worker_queue_dir_24f4ecb="$TEMP_DIR/worker-queue"
  mkdir -p "$worker_queue_dir_24f4ecb"
  touch "$worker_queue_dir_24f4ecb"/wids
  prepend_cleanup cleanup_worker_queue
}

#endregion

# ==========================================================================
#region

# Check if arguments are passed.
_() {
  local rc=1
  local saved_extdebug
  saved_extdebug="$(shopt -p extdebug || :)"
  shopt -s extdebug
  [[ "${BASH_ARGV[0]}" != "${BASH_SOURCE[0]}" ]] && rc=0
  eval "$saved_extdebug"
  return "$rc"
}

if test $# -gt 0 && _
then
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (init-temp|init-temp-dir) register_temp_cleanup;;
      (init-worker-queue) init_worker_queue;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))
fi

#endregion
