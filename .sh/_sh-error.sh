#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_12859cd-false}" && return 0; sourced_12859cd=true

set -o nounset -o errexit

foo() {
  echo foo1 >&2
  false
  echo foo2 >&2
}

# Ofcourse, foo2 not shown
# foo

# Not shown too
# f="$(foo)"

foo_parent() {
  # This does not fail
  # local f="$(foo)" || return $?
  # This fails
  local f; f="$(foo)" || return $?
  echo "$f"
}

if ! foo_parent
then
  echo foo_parent failed >&2
fi

# Shown. foo does not stop the execution and the rc of foo is 0
if foo
then
  echo Unfortunetely, foo looks succeeded >&2
else
  echo foo failed >&2
fi

# `-e` Exit immediately if a pipeline, which may consist of a single simple command, a subshell command enclosed in parentheses, or one of the commands executed as part of a command list enclosed by braces returns a non-zero status. **The shell does not exit** if the command that fails is part of the command list immediately following a `while` or `until` keyword, part of the test in an `if` statement, **part of any command executed in a `&&` or `||` list except the command following the final `&&` or `||`**, any command in a pipeline but the last, or if the command’s return status is being inverted with `!`.
# 
# — The Set Builtin (Bash Reference Manual) https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html

# I must write explicit return
bar() {
  local rc
  echo bar1 >&2
  false
  rc=$?; test "$rc" -ne 0 && return "$rc"
  echo bar2 >&2
}

if ! bar
then
  echo bar failed >&2
fi

bar || echo bar failed2 >&2

# Or, immediately return $? if possible
baz() {
  echo baz1 >&2
  false || return $?
  echo baz2 >&2
}

baz || echo baz failed >&2
