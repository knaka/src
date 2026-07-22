# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a32832b-false}" && return 0; sourced_a32832b=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
shift 2
cd "$1" || exit 1; shift 2

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
    watchexec --postpone --only-emit-events \
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

gen() {
  echo Building
  touch README.md
}

task_gen() {
  local force=false
  local watch=false
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (force) force=true;;
      (watch) watch=true;;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  set -- "source/*.txt"

  if "$watch"
  then
    init_temp_dir
    local modified_file_list="$TEMP_DIR"/0ec5e8a
    touch "$modified_file_list"
    while :
    do
      echo Do something for:
      cat "$modified_file_list"
      gen
      sleep 1
      wait_for_change "$@" >"$modified_file_list"
    done
  elif "$force" || updated $@ --than README.md
  then
    gen
  fi
}
