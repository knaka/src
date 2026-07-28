#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ _LIB_MEMOIZE_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@" # shpp:begin_source
. ./utils.sh
cd "$3" || exit; shift 3 # shpp:end_source

# Run "$@" once and cache its stdout, keyed by the command line. A later call
# with the same arguments replays the cached output instead of re-running.
# The exit status of "$@" is returned; on failure the cache entry is dropped
# so the next call retries instead of replaying the failed output.
memoize() {
  init_temp_dir
  local cache_file_path
  cache_file_path="$TEMP_DIR"/memoize-"$(echo "$@" | sha256sum | cut -d' ' -f1)"
  test -r "$cache_file_path" && cat "$cache_file_path" && return 0
  local rc=0
  if is_bbwin
  then
    "$@" >"$cache_file_path" || rc=$?
    cat "$cache_file_path"
    test $rc -ne 0 && rm -f "$cache_file_path"
    return $rc
  fi
  local fifo_path="$TEMP_DIR"/1f1ff14
  mkfifo "$fifo_path"
  "$@" >"$fifo_path" &
  local pid=$!
  tee "$cache_file_path" <"$fifo_path"
  rm -f "$fifo_path"
  wait "$pid" || rc=$?
  test "$rc" -ne 0 && rm -f "$cache_file_path"
  return "$rc"
}

fifo_path_1af0d3e=
tee_pid_2b6e9c4=
cache_file_path_cb3727b=

# Begin memoizing the stdout of the code between this call and the matching
# end_memoize, keyed by "$@". Redirects the current shell's stdout so output
# is both streamed live and saved to the cache file. If a cached entry
# already exists, it is replayed immediately and 1 is returned so the caller
# can skip the block, e.g. `try_memoize KEY "$@" || return 0`. Uses global
# state, so calls cannot be nested/reentered before end_memoize runs.
try_memoize() {
  test -n "$tee_pid_2b6e9c4" && return 1
  cache_file_path_cb3727b="$TEMP_DIR"/block-memoize-"$(printf "%s" "$@" | sha256sum | cut -d' ' -f1)"
  test -r "$cache_file_path_cb3727b" && cat "$cache_file_path_cb3727b" && return 1
  if is_bbwin
  then
    exec 9>&1 >"$cache_file_path_cb3727b"
    return
  fi
  fifo_path_1af0d3e="$TEMP_DIR"/fifo-47374f3
  mkfifo "$fifo_path_1af0d3e"
  exec 9>&1
  tee "$cache_file_path_cb3727b" <"$fifo_path_1af0d3e" >&9 &
  tee_pid_2b6e9c4=$!
  exec >"$fifo_path_1af0d3e"
}

# Close a memoization block opened by try_memoize: restores stdout and waits
# for the background `tee` to finish writing the cache file before returning.
end_memoize() {
  exec 1>&9 9>&-
  if is_bbwin
  then
    cat "$cache_file_path_cb3727b" && return
  fi
  wait "$tee_pid_2b6e9c4"
  tee_pid_2b6e9c4=
  rm -f "$fifo_path_1af0d3e"
  fifo_path_1af0d3e=
}
