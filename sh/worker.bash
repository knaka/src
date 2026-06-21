# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
"${sourced_0f8a56d-false}" && return 0; sourced_0f8a56d=true

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.lib.bash
popd >/dev/null || exit 1

run-worker() {
  local log_file
  log_file="$(mktemp "$TEMP_DIR"/log.XXXXX)"
  touch "$log_file"
  "$@" >"$log_file" 2>&1 &
  local pid="$!"
  echo "$pid"
  echo "$log_file" >"$TEMP_DIR"/"$pid"
  echo "$@" >"$TEMP_DIR"/args."$pid"
}

tail-worker() (
  log_file="$(cat "$TEMP_DIR"/"$1")"
  trap : INT
  set -m
  tail -f "$log_file" || :
)

stop-workers() {
  local wid
  for wid in "$@"
  do
    kill "$wid"
    sleep 0.1
    while kill -0 "$wid" >/dev/null 2>&1
    do
      sleep 0.1
    done
    echo "Stopped worker: \"$(cat "$TEMP_DIR"/args."$wid")\"" >&2
  done
}

worker() {
  register_temp_cleanup
  local wid1 wid2
  wid1="$(run-worker bash ./loop.bash 1)"
  wid2="$(run-worker bash ./loop.bash 2)"
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
        tail-worker "$wid1"
        ;;
      (tail2)
        tail-worker "$wid2"
        ;;
      (exit) break;;
      (*) ;;
    esac
  done
  stop-workers "$wid1" "$wid2"
}

case "${0##*/}" in
  ("${BASH_SOURCE[0]##*/}"|"${BASH_SOURCE[0]##*/}".bash)
    set -o nounset -o errexit -o pipefail
    worker "$@"
    ;;
esac
