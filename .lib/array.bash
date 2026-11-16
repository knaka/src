#!/usr/bin/env bash
set -- _a7b3112 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Append the lines of the standard input to the array whose name is given, one element per line. The array is assigned through `read` and `unset`, which take a variable name, including an array element, as an argument, so `eval` is not needed.
# Usage: array_append_stdin array_name <...
array_append_stdin() {
  local array_name_59794c1="$1"
  # Start from the current number of elements, so that the lines are appended.
  local array_ref_8aa31f1="$1[@]"
  set -- ${!array_ref_8aa31f1+"${!array_ref_8aa31f1}"}; local i_f0ff9e3=$#
  while IFS= read -r "${array_name_59794c1}[$i_f0ff9e3]"
  do
    i_f0ff9e3=$((i_f0ff9e3 + 1))
  done
  # The read that hits the end of the input assigns an empty string, or the last line if it does not end with a newline. Remove the element if it is empty.
  local last_ref_802d075="${array_name_59794c1}[$i_f0ff9e3]"
  test -n "${!last_ref_802d075}" || unset "${array_name_59794c1}[$i_f0ff9e3]"
}

# Run the command given after the array name once for each element of the array, with the element appended as the last argument.
# Usage: array_foreach array_name command [args...]
array_for_each() {
  # The array is referred to by name through indirect expansion, which works even on Bash 3, where namerefs are not available. Nothing is run for an empty array, even with nounset.
  # Give the local variables unique names so that they do not conflict with the variable names of the caller.
  local array_ref_7edf617="$1[@]"
  shift
  local item_cb9b7e7
  for item_cb9b7e7 in ${!array_ref_7edf617+"${!array_ref_7edf617}"}
  do
    "$@" "$item_cb9b7e7"
  done
}

array() {
  echo "Function \"array\" is not implemented yet."
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 array "$@"
fi
