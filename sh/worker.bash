# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
"${sourced_0f8a56d-false}" && return 0; sourced_0f8a56d=true

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.lib.bash
popd >/dev/null || exit 1

worker-run() {
  local log_file
  log_file="$(mktemp "$TEMP_DIR"/log.XXXXX)"
  touch "$log_file"
  set -m
  "$@" >"$log_file" 2>&1 &
  local pid="$!"
  echo "$pid"
  echo "$log_file" >"$TEMP_DIR"/"log-file.$pid"
  echo "$@" >"$TEMP_DIR"/args."$pid"
}

worker-tail() (
  log_file="$(cat "$TEMP_DIR"/"log-file.$1")"
  trap : INT
  set -m
  tail -f "$log_file" || :
)

worker-log() {
  local log_file
  log_file="$(cat "$TEMP_DIR"/"log-file.$1")"
  cat "$log_file"
}

workers-stop() {
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

worker() {
  register_temp_cleanup
  local wid1 wid2
  wid1="$(worker-run bash ./loop.bash 1)"
  wid2="$(worker-run bash ./loop.bash 2)"
  local result=tail1
  while :
  do
    result="$(gum choose --selected="$result" \
      "tail1" \
      "tail2" \
      "exit" \
      #nop
    )"
    case "$result" in
      (tail1)
        worker-tail "$wid1"
        ;;
      (tail2)
        worker-tail "$wid2"
        ;;
      (exit) break;;
      (*) ;;
    esac
  done
  workers-stop "$wid1" "$wid2"
}

case "${0##*/}" in
  ("${BASH_SOURCE[0]##*/}"|"${BASH_SOURCE[0]##*/}".bash)
    set -o nounset -o errexit -o pipefail
    worker "$@"
    ;;
esac
