# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
  init_temp
. ./.lib/test.bash
popd >/dev/null || exit 1

run_tests() {
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
