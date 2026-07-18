#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 53a9884 && return 0

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 
case "${1:+$1}" in (_LIBDIR) cd "$2" || exit 1;; (*) cd "$_APPDIR" || exit 1;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit 1; shift

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
