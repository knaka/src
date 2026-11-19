#!/usr/bin/env bash
set -- _JS__MISE_TASKS_PROJECT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../../.lib/utils.sh
. ../../.lib/percent-encode.sh
popd >/dev/null || exit

# Wrap the code in an IIFE so that it does not pollute or conflict with the variables of the page and does not replace the page with its result, and URL-encode it, since the browser percent-decodes a javascript: URL before running it and the URL cannot contain raw newlines.
gen_bookmarklet() {
  printf "javascript:"
  {
    printf "(() => {\n"
    if test $# -gt 0
    then
      cat "$1"
    else
      cat
    fi
    printf "\n})();\n"
  } \
  | percent_encode
  echo
}

# Check the types of the TypeScript files with tsc, without emitting any files.
task_check() {
  tsc --project "$PROJECT_DIR"/tsconfig.json
}

# Check the types, and bundle the scripts into dist/ with build.mjs.
task_build() {
  task_check
  # file://./../build.mjs
  node "$PROJECT_DIR"/build.mjs
}

# [files...] Create bookmarklet.
task_bookmarklet() {
  local file
  for file in "$@"
  do
    gen_bookmarklet <"$file"
  done
}
