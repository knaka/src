#!/usr/bin/env bash
set -- _13e0418 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/array.bash
popd >/dev/null || exit

foo_c368879() {
  echo Hello World
  echo Foo Bar
}

assign_stdout1() {
  local -a my_array=(Bar Baz)
  array_append_stdin my_array < <(foo_c368879)
  array_for_each my_array echo "d1:"
}

assign_stdout2() {
  local my_array=()
  IFS=$'\n' read -r -d '' -a my_array < <(foo_c368879) || :
  local count=0
  _() {
    ((++count))
    echo "d2-0:" "$1"
    echo "d2-1:" "$1"
  }
  array_for_each my_array _
  echo count "$count"
}

assign_stdout_to_array() {
  local var_name=
  OPTIND=1; while getopts _-:v: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (v) var_name="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local rc=0
  init_temp_dir
  local fifo_path="$TEMP_DIR"/b91713c
  mkfifo "$fifo_path"
  "$@" >"$fifo_path" &
  local pid=$!
  IFS=$'\n' read -r -d '' -a "$var_name" <"$fifo_path" || :
  wait "$pid" || rc=$?
  return "$rc"
}

assign_stdout3() {
  # shellcheck disable=SC2034
  local -a my_array=()
  assign_stdout_to_array -v my_array foo_c368879
  array_for_each my_array echo "d3:"
}

not_assign() {
  while read -r
  do
    echo d4: "$REPLY"
  done \
  < <(foo_c368879) \
  | cat -n
}

assign_stdout() {
  assign_stdout1 "$@"
  echo

  assign_stdout2 "$@"
  echo

  assign_stdout3 "$@"
  echo

  not_assign "$@"
  echo
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 assign_stdout "$@"
fi
