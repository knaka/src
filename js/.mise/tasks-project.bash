#!/usr/bin/env bash
set -- _0859dd3 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../../.lib/utils.sh
. ../../.lib/urlencode.sh
popd >/dev/null || exit

# [files...] Create bookmarklet.
task_bookmarklet() {
  local file
  for file in "$@"
  do
    # Wrap the code in an IIFE so that it does not pollute or conflict with the variables of the page and does not replace the page with its result, and URL-encode it, since the browser percent-decodes a javascript: URL before running it and the URL cannot contain raw newlines.
    printf "javascript:"
    {
      printf "(() => {\n"
      cat "$file"
      printf "\n})();\n"
    } \
    | urlencode
    echo
  done
}
