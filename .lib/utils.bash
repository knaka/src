# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
"${sourced_e76ec9d-false}" && return 0; sourced_e76ec9d=true

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./utils.lib.sh
popd >/dev/null || exit 1

run-worker() {
  local log_file
  log_file="$(mktemp "$TEMP_DIR"/log.XXXXX)"
  touch "$log_file"
  set -m
  "$@" </dev/null >"$log_file" 2>&1 &
  local pid="$!"
  echo "$pid"
  echo "$log_file" >"$TEMP_DIR"/"log-file.$pid"
  echo "$@" >"$TEMP_DIR"/args."$pid"
}

tail-worker() (
  log_file="$(cat "$TEMP_DIR"/"log-file.$1")"
  trap : INT
  set -m
  tail -f "$log_file" || :
)

stop-workers() {
  local wid
  for wid in "$@"
  do
    echo "Killing worker: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
    kill -TERM "$wid"
  done
  sleep 1
  for wid in "$@"
  do
    echo "Stopping worker: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
    while kill -0 "$wid" >/dev/null 2>&1
    do
      sleep 0.1
    done
    echo "Stopped worker: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
  done
  return 0
}
