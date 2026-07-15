#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 39d4dc0 && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/map.sh
shift 2
set -- _LIBDIR ../.lib-test "$@"
. ../.lib-test/test.sh
shift 2
cd "$1" || exit; shift

run_tests() {
  local sh=sh
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (full) should_run_fulltest_80e79eb=true;;
      (sh) sh="$OPTARG";;
      (verbose) VERBOSE=true;;
      (?) exit 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  cd "${INITIAL_DIR-}" || return

  local RED=""
  local GREEN=""
  local YELLOW=""
  local NORMAL=""
  if is_terminal
  then
    RED="${ch_esc}[31m"
    GREEN="${ch_esc}[32m"
    YELLOW="${ch_esc}[33m"
    NORMAL="${ch_esc}[00m"
  fi

  local test_path="$PWD"/.lib-test
  local lib_path="$PWD"/.lib
  local RESULT
  local test_file_map=
  set_result "$test_file_map"
  local file
  for file in \
    "$test_path"/*-test.shlib \
    "$test_path"/test-*.sh \
    "$test_path"/tests-*.sh \
    "$test_path"/test-*.shlib \
    "$test_path"/tests-*.bash \
    "$lib_path"/*.sh \
    "$lib_path"/*.bash \
    #nop
  do
    test -r "$file" || continue
    "$VERBOSE" && echo "Reading test file \"$file\" in $PWD." >&2
    local test
    # shellcheck disable=SC2013
    for test in $(sed -n -e 's/^test_\([_a-zA-Z0-9]*\)[[:space:]]*()[[:space:]]*{[[:space:]]*$/\1/p' "$file")
    do
      mput_ "$RESULT" "$test" "$file"
    done
  done
  test_file_map="$RESULT"
  if test -z "$test_file_map"
  then
    echo No test available. >&2
    return 0
  fi
  
  mkeys_ "$test_file_map"
  local tests="$RESULT"
  local test
  
  local tests_to_run
  if test $# -eq 0
  then
    tests_to_run="$tests"
  else
    set_resultf "%s$ch_us" "$@"
    test "$RESULT" = "$ch_us" && RESULT=
    tests_to_run="$RESULT"
  fi
  test "$tests_to_run"

  local some_failed=false
  register_temp_cleanup
  local log_file_path="$TEMP_DIR/296ef1c"
  local IFS="$ch_us"
  for test in $tests_to_run
  do
    unset IFS
    if ! mget_ "$test_file_map" "$test"
    then
      printf "%sTest \"%s\" is not defined\n" "$RED" "$test" >&2
      some_failed=true
      continue
    fi
    local file="$RESULT"
    local rc=0
    local dir="${file%[/\\]*}"
    local base="${file##*[/\\]}"
    local stmts="cd '$dir'; _APPDIR=\"\$PWD\"; . ./'$base'; test_$test" >"$log_file_path"
    case "$file" in
      (*.sh)
        $sh -o nounset -o errexit -c "$stmts" >"$log_file_path" 2>&1 || rc=$?
        ;;
      (*.bash)
        bash -o nounset -o errexit -o pipefail -c "$stmts" >"$log_file_path" 2>&1 || rc=$?
        ;;
    esac
    local base="${file##*[/\\]}"
    if test "$rc" -eq 0
    then
      printf "%sTest \"%s\"@%s Passed%s\n" "$GREEN" "$test" "$base" "$NORMAL" >&2
      if "$VERBOSE"
      then
        test -r "$log_file_path" && sed -e 's/^/  /' <"$log_file_path" >&2
      fi
    elif test "$rc" -eq "$rc_test_skipped"
    then
      printf "%sTest \"%s\"@%s Skipped%s\n" "$YELLOW" "$test" "$base" "$NORMAL" >&2
    else
      printf "%sTest \"%s\"@%s Failed with RC %d%s\n" "$RED" "$test" "$base" "$rc" "$NORMAL" >&2
      test -r "$log_file_path" && sed -e 's/^/  /' <"$log_file_path" >&2
      some_failed=true
    fi
  done
  unset IFS

  "$some_failed" && return 1
  return 0
}

# [names...] Run tests. If no test names are provided, all tests are run.
task_test() {
  run_tests "$@"
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ tasks-test
then
  set -o nounset -o errexit
  run_tests "$@"
fi
