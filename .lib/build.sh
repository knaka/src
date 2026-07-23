#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 41b4cc6 && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit; shift

pid_4ec98eb=
fifo_path_4ec98eb=

on_exit_0e51f30() {
  if test -n "$pid_4ec98eb"
  then
    kill "$pid_4ec98eb" >/dev/null 2>&1 || :
    wait "$pid_4ec98eb" >/dev/null 2>&1 || :
    pid_4ec98eb=
  fi
  exec 3<&- 2>/dev/null || :
  test -n "$fifo_path_4ec98eb" && rm -f "$fifo_path_4ec98eb"
  fifo_path_4ec98eb=
}

# Block until a batch of changes to the given filter patterns is detected,
# then return success (0). Meant to be called repeatedly in a loop with the
# same patterns: `watchexec --only-emit-events` is started just once, on the
# first call, and kept running/streaming in the background across
# subsequent calls, rather than being relaunched every time. Returns
# failure (1) if the underlying watchexec process dies.
wait_for_change() {
  if test -z "$pid_4ec98eb"
  then
    trap_terminating_signals
    add_exit_handler on_exit_0e51f30
    init_temp_dir

    local arg
    for arg in "$@"
    do
      shift
      set -- "$@" --filter="$arg"
    done

    fifo_path_4ec98eb="$(mktemp "$TEMP_DIR"/XXXXXX)"
    rm -f "$fifo_path_4ec98eb"
    mkfifo "$fifo_path_4ec98eb"
    watchexec --no-discover-ignore --postpone \
      --only-emit-events \
      --emit-events-to=stdio \
      "$@" >"$fifo_path_4ec98eb" 2>/dev/null &
    pid_4ec98eb=$!
    exec 3<"$fifo_path_4ec98eb"
  fi
  local line
  while IFS= read -r line <&3
  do
    test -z "$line" && return 0
    echo "$line"
  done
  return 1
}

depbuild() {
  local force=false
  local watch=false
  local handler=_
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (force) force=true;;
      (handler) handler="$OPTARG";;
      (watch) watch=true;;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local target="$1"
  shift

  if "$watch"
  then
    init_temp_dir
    local modified_file_list="$TEMP_DIR"/0ec5e8a
    rm -f "$modified_file_list"
    touch "$modified_file_list"
    while :
    do
      local IFS="$CH_LF"
      # shellcheck disable=SC2046
      "$handler" $(cat "$modified_file_list")
      unset IFS
      sleep 1
      wait_for_change "$@" >"$modified_file_list"
    done
    return 1
  fi

  local IFS=
  # shellcheck disable=SC2068
  set -- $@
  unset IFS
  if "$force" || updated "$@" --after "$target"
  then
    "$handler" "$@"
  fi
}
