#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __MISE_TASKS_TEST_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
echo b182e31 >&2
pwd
. ../.lib/utils.sh
echo bf9087d >&2
. ../.lib/collection.sh
. ../.lib/string.sh
. ../.lib/test.sh
cd "$3" || exit; shift 3 # /shpp:sources

run_tests() {
  local sh=sh
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
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
    RED="${CH_ESC}[31m"
    GREEN="${CH_ESC}[32m"
    YELLOW="${CH_ESC}[33m"
    NORMAL="${CH_ESC}[00m"
  fi

  local test_path="$PWD"/.lib-test
  local lib_path="$PWD"/.lib

  local RESULT=
  
  map_
  local file
  for file in \
    "$test_path"/*-test.shlib \
    "$test_path"/tests-*.sh \
    "$test_path"/tests-*.bash \
    "$lib_path"/*.sh \
    "$lib_path"/*.bash \
    "$test_path"/test_*.sh \
    "$test_path"/test_*.bash \
    #nop
  do
    test -r "$file" || continue
    case "$file" in
      (*.bash)
        is_bbwin && continue
        ;;
    esac
    local test
    local base
    base="${file##*[/\\}"
    case "$base" in
      (test_*)
        test="${base#test_}"
        test="${test%.*}"
        mput_ "$RESULT" "$test" "$file"
        continue
        ;;
    esac
    "${VERBOSE-false}" && echo "Reading test file \"$file\" in $PWD." >&2
    # shellcheck disable=SC2013
    for test in $(sed -n -e 's/^test_\([_a-zA-Z0-9]*\)[[:space:]]*()[[:space:]]*{[[:space:]]*$/\1/p' "$file")
    do
      mput_ "$RESULT" "$test" "$file"
    done
  done
  local test_file_map="$RESULT"
  if test -z "$test_file_map"
  then
    echo No test available. >&2
    return 0
  fi
  
  mkeys_ "$test_file_map"
  # vshuf_ "$RESULT"
  local all_tests="$RESULT"
  
  local tests_to_run
  if test $# -gt 0
  then
    vec_ "$@"
    tests_to_run="$RESULT"
  else
    tests_to_run="$all_tests"
  fi

  init_temp_dir
  local log_file_path="$TEMP_DIR/296ef1c"
  local some_failed=false
  _() {
    local test="$1"
    if ! mget_ "$test_file_map" "$test"
    then
      case "$test" in
        (test_*)
          test="${test#test_}"
          ;;
        (*[/\\]test_*)
          test="${test##*[/\\]test_}"
          test="${test%.*}"
          ;;
      esac
      if ! mget_ "$test_file_map" "$test"
      then
        printf "%sTest \"%s\" is not defined\n" "$RED" "$test" >&2
        some_failed=true
        return
      fi
    fi
    local file="$RESULT"
    local rc=0
    local dir="${file%[/\\]*}"
    local base="${file##*[/\\]}"
    local stmts="cd '$dir'; set -- _SCRDIR \"\$PWD\" \"\$@\"; . ./'$base'; test_$test"
    case "$base" in
      (test-*.sh)
        $sh -o nounset -o errexit "$file" >"$log_file_path" 2>&1 || rc=$?
        ;;
      (test-*.bash)
        bash -o nounset -o errexit -o pipefail "$file" >"$log_file_path" 2>&1 || rc=$?
        ;;
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
      if "${VERBOSE-false}"
      then
        test -r "$log_file_path" && sed -e 's/^/  /' <"$log_file_path" >&2
      fi
    elif test "$rc" -eq "$RC_TEST_SKIPPED"
    then
      printf "%sTest \"%s\"@%s Skipped%s\n" "$YELLOW" "$test" "$base" "$NORMAL" >&2
    else
      printf "%sTest \"%s\"@%s Failed with RC %d%s\n" "$RED" "$test" "$base" "$rc" "$NORMAL" >&2
      test -r "$log_file_path" && sed -e 's/^/  /' <"$log_file_path" >&2
      some_failed=true
    fi
  }; veach "$tests_to_run" _
  "$some_failed" && return 1
  return 0
}

# [names...] Run tests. If no test names are provided, all tests are run.
task_test() {
  run_tests "$@"
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.tasks-test.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  run_tests "$@"
fi
