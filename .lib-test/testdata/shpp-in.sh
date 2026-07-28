#!/usr/bin/env sh
echo original line # shpp:source_guard

echo aaa # shpp:begin_source
. ../.lib/utils.sh
echo bbb # shpp:end_source


echo hello
x=abc
echo world "$x"

echo foo
echo bar


echo bar baz

bar() {
  echo "Function \"bar\" is not implemented yet."
}

echo aaa # shpp:main_guard
then
  set -o nounset -o errexit
  bar "$@"
fi
