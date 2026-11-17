#!/usr/bin/env bash
set -- __LIB_ARRAY_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ./utils.sh
popd >/dev/null || exit

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

# Assign the lines of the standard input to the array whose name is given, one element per line, replacing the current elements.
# Usage: array_assign_stdin array_name <...
array_assign_stdin() {
  read -r -a "$1" </dev/null || :
  array_append_stdin "$1"
}

# Run the command given after the array name once for each element of the array, with the element appended as the last argument.
# Usage: array_for_each array_name command [args...]
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

# ==========================================================================
#region Map, an associative array implemented as a property list.

result_array_6b44f76=()

print_result_array_to() {
  if test -n "$1"
  then
    eval "$1=(\${result_array_6b44f76[@]+\"\${result_array_6b44f76[@]}\"})"
  else
    test ${#result_array_6b44f76[@]} -eq 0 || printf '%s\n' "${result_array_6b44f76[@]}"
  fi
}

array_mkeys_3d2a089() {
  local array_ref="$1[@]"
  local in_array=(${!array_ref+"${!array_ref}"})
  local result=()
  while test ${#in_array[@]} -ge 2
  do
    result+=("${in_array[0]}")
    in_array=("${in_array[@]:2}")
  done
  result_array_6b44f76=(${result[@]+"${result[@]}"})
}

# Print the keys of the array whose name is given, treating it as an alternating list of keys and values, one key per line, or assign them to the array given with "-v var" without using a subshell.
# Usage: array_mkeys [-v var] array_name
array_mkeys() {
  local var_name_43adc06=
  test "${1-}" = "-v" && var_name_43adc06="$2" && shift 2
  array_mkeys_3d2a089 "$@"
  print_result_array_to "$var_name_43adc06"
}

array_mput_3ff445a() {
  local array_ref="$1[@]"
  local key="$2"
  local value="$3"
  local in_array=(${!array_ref+"${!array_ref}"})
  local result=()
  while test ${#in_array[@]} -ge 2
  do
    if test "${in_array[0]}" != "$key"
    then
      result+=("${in_array[0]}" "${in_array[1]}")
    fi
    in_array=("${in_array[@]:2}")
  done
  result+=("$key" "$value")
  result_array_6b44f76=("${result[@]}")
}

# Put the value for the key in the array whose name is given, treating it as an alternating list of keys and values, and print the elements of the resulting array, one element per line, or assign them to the array given with "-v var". The current entry for the key, if any, is removed, and the new one is put at the end. The variable can be the same as the given array, to update it in place.
# Usage: array_mput [-v var] array_name key value
array_mput() {
  local var_name_d8b6ad6=
  test "${1-}" = "-v" && var_name_d8b6ad6="$2" && shift 2
  array_mput_3ff445a "$@"
  print_result_array_to "$var_name_d8b6ad6"
}

result_c5d37ac=

array_mget_b0d29f2() {
  local array_ref="$1[@]"
  local key="$2"
  local in_array=(${!array_ref+"${!array_ref}"})
  while test ${#in_array[@]} -ge 2
  do
    if test "${in_array[0]}" = "$key"
    then
      result_c5d37ac="${in_array[1]}"
      return 0
    fi
    in_array=("${in_array[@]:2}")
  done
  return 1
}

# Print the value for the key in the array whose name is given, treating it as an alternating list of keys and values, or assign it to the variable given with "-v var". Fail if the key is not found.
# Usage: array_mget [-v var] array_name key
array_mget() {
  local var_name_c37dd41=
  test "${1-}" = "-v" && var_name_c37dd41="$2" && shift 2
  array_mget_b0d29f2 "$@" || return $?
  print_to "$var_name_c37dd41" "$result_c5d37ac"
}

#endregion
