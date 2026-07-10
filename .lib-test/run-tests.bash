# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash

if test "${BASH_VERSION+set}" != set || test "${POSIXLY_CORRECT+set}" = set
then
  echo This test runner is for BASH. >&2
  # shellcheck disable=SC2317
  return 0 2>/dev/null || exit 0
fi

{ pushd "${BASH_SOURCE[0]%/*}" || pushd "${BASH_SOURCE[0]%\\*}" || pushd .; } >/dev/null 2>&1
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
  init_temp
shift 2
popd >/dev/null || exit 1
. ./test.sh

run_tests() {
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (full) should_run_fulltest_80e79eb=true;;
      (?) exit 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  local RED=""
  local GREEN=""
  local YELLOW=""
  local NORMAL=""
  if is_terminal
  then
    RED=$(printf "\033[31m")
    GREEN=$(printf "\033[32m")
    YELLOW=$(printf "\033[33m")
    NORMAL=$(printf "\033[00m")
  fi

  local appdir="${BASH_SOURCE[0]%/*}"
  cd "$appdir" || exit 1
  local file
  for file in ./tests-*.bash
  do
    # shellcheck disable=SC1090
    . "$file"
  done
  local tests=
  if test $# -gt 0
  then
    tests="$* "
  else
    while read -r
    do
      tests="$tests${REPLY#test_} "
    done < <(compgen -A function test_ | sort -n)
  fi

  local log_file_path="$TEMP_DIR"/485d347
  local some_failed=false
  for test_name in $tests
  do
    if ! LC_ALL=C type "test_$test_name" 2>/dev/null | grep -q -E -e 'function$'
    then
      echo "Test not found: $test_name" >&2
      return 1
    fi
    local restore_errexit="set +o errexit"
    [[ $- = *e* ]] && restore_errexit="set -o errexit"
    set +o errexit
    # Run test in a subshell with errexit enabled. This allows the test to exit immediately on error while the parent shell continues to run subsequent tests.
    (
      set -o errexit
      "test_$test_name"
    ) >"$log_file_path" 2>&1
    local rc=$?
    eval "$restore_errexit"
    if test "$rc" -eq 0
    then
      printf "%sTest \"%s\" Passed%s\n" "$GREEN" "$test_name" "$NORMAL" >&2
      if "$VERBOSE"
      then
        sed -e 's/^/  /' <"$log_file_path" >&2
      fi
    elif test "$rc" -eq "$rc_test_skipped"
    then
      printf "%sTest \"%s\" Skipped%s\n" "$YELLOW" "$test_name" "$NORMAL" >&2
    else
      printf "%sTest \"%s\" Failed with RC %d%s\n" "$RED" "$test_name" "$rc" "$NORMAL" >&2
      sed -e 's/^/  /' <"$log_file_path" >&2
      some_failed=true
    fi
  done
  $some_failed && return 1
  return 0
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  run_tests "$@"
fi
