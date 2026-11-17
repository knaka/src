#!/usr/bin/env bash
set -- _c2a88df "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/array.bash
popd >/dev/null || exit

func_718dc44() {
  echo 1st
  echo 2nd
}

array() {
  # # local a=($(func_718dc44))
  # # read -r -a a < <(func_718dc44) || :
  # local a
  # array_assign_stdin a < <(func_718dc44)
  # local x
  # for x in ${a[@]+"${a[@]}"}
  # do
  #   echo "$x"
  # done

  local a=("k \" 1" v1 "k 2" v2 "" v3 "k${CH_LF}4${CH_LF}" v4)
  local var_name=a
  local array_ref="$var_name[@]"
  local copied_array=("${!array_ref}")
  echo 884957d "${#copied_array[@]}" >&2
  test 8 -eq "${#copied_array[@]}"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 array "$@"
fi
