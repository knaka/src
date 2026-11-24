#!/usr/bin/env bash
set -- _JS__MISE_TASKS_PROJECT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/percent-encode.sh
popd >/dev/null || exit

# Wrap the code in an IIFE so that it does not pollute or conflict with the variables of the page and does not replace the page with its result, and URL-encode it, since the browser percent-decodes a javascript: URL before running it and the URL cannot contain raw newlines.
gen_bookmarklet() {
  local newline="$CH_LF"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (compact ) newline="";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  printf "javascript:"
  {
    printf "(() => {%s" "$newline"
    if test $# -gt 0
    then
      cat "$1"
    else
      cat
    fi
    printf "%s})();%s" "$newline" "$newline"
  } \
  | percent_encode
  echo
}

# [files...] Create bookmarklet.
task_bookmarklet() {
  local file
  for file in "$@"
  do
    gen_bookmarklet <"$file"
  done
}

# Check the types of the TypeScript files with tsc, without emitting any files.
task_check() {
  tsc --project "$PROJECT_DIR"/tsconfig.json
}

# Check the types, and bundle the scripts into dist/ with build.mjs.
task_build() {
  task_check
  node ./build.mjs
  local x
  # shellcheck disable=SC2043
  for x in copy-link
  do
    gen_bookmarklet --compact "$PROJECT_DIR"/dist/"$x".js >"$PROJECT_DIR"/dist/"$x".bookmarklet
  done
}
