#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_COLLECTION_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

# Collections held in a single string, for shells without arrays.
# A vector is a string of items, each followed by the unit separator ($CH_US), such as "a␟b␟c␟". A map is a vector of keys and values in turn, that is, a property list, such as "key1␟value1␟key2␟value2␟", whose separator can be changed with "-s".
# Each function that outputs a value prints it, or assigns it to the variable given with "-v var" as printf of Bash does. The value is computed by an inner function with a hash-suffixed name, which sets it to result_8572e4b and is free to use any local variables, so that they do not shadow the variable whose name is given by the caller.

result_8572e4b=

# ==========================================================================
#region Vector.

vec_0906ef2() {
  result_8572e4b=
  local item
  for item in "$@"
  do
    result_8572e4b="$result_8572e4b$item$CH_US"
  done
}

# Make a vector of the arguments.
# Usage: vec [-v var] [item...]
vec() {
  local var_name_bd9ead0=
  test "${1-}" = "-v" && var_name_bd9ead0="$2" && shift 2
  vec_0906ef2 "$@"
  print_to "$var_name_bd9ead0" "$result_8572e4b"
}

# Check if the vector is empty.
# Usage: vempty vector
vempty() {
  test -z "$1"
}

vsort_nul_8f48320() {
  result_8572e4b="$(
    printf "%s" "$1" \
    | tr "$CH_US" '\0' \
    | "$2" \
    | tr '\0' "$CH_US" \
    #nop
  )"
}

# Reorder the items of the vector with the command given, which reads and writes the items separated by NUL characters, as `sort -z` does.
# Usage: vsort_nul [-v var] vector command
vsort_nul() {
  local var_name_7525161=
  test "${1-}" = "-v" && var_name_7525161="$2" && shift 2
  vsort_nul_8f48320 "$@"
  print_to "$var_name_7525161" "$result_8572e4b"
}

sort_9835641() {
  sort -z
}

# Sort the items of the vector.
# Usage: vsort [-v var] vector
vsort() {
  local var_name_34792be=
  test "${1-}" = "-v" && var_name_34792be="$2" && shift 2
  vsort_nul_8f48320 "$1" sort_9835641
  print_to "$var_name_34792be" "$result_8572e4b"
}

shuf_28cd8b4() {
  sort -z -R
}

# Shuffle the items of the vector.
# Usage: vshuf [-v var] vector
vshuf() {
  local var_name_54d6184=
  test "${1-}" = "-v" && var_name_54d6184="$2" && shift 2
  vsort_nul_8f48320 "$1" shuf_28cd8b4
  print_to "$var_name_54d6184" "$result_8572e4b"
}

# Run the command given once for each item of the vector, with the item as the argument. The command defaults to "_".
# Usage: veach vector [command]
veach() {
  # Give the local variables unique names, so that they do not shadow the variables which the command refers to.
  local func_356bc59="${2-_}"
  local item_356bc59
  local IFS="$CH_US"
  for item_356bc59 in $1
  do
    unset IFS
    "$func_356bc59" "$item_356bc59"
  done
}

#endregion

# ==========================================================================
#region Map, an associative array implemented as a property list.

# Make a map of the arguments, which are keys and values in turn.
# Usage: map [-v var] [key value...]
map() {
  local var_name_ed2db0d=
  test "${1-}" = "-v" && var_name_ed2db0d="$2" && shift 2
  vec_0906ef2 "$@"
  print_to "$var_name_ed2db0d" "$result_8572e4b"
}

# Usage: mput_7ab208c separator map key value
mput_7ab208c() {
  local sep="$1"
  local key="$3"
  local value="$4"
  local IFS="$sep"
  # shellcheck disable=SC2086
  set -- $2
  local i=0
  local n=$(($#/2))
  while test "$i" -lt "$n"
  do
    test "$1" != "$key" && set -- "$@" "$1" "$2"
    shift 2
    i=$((i+1))
  done
  set -- "$@" "$key" "$value"
  result_8572e4b=
  local item
  for item in "$@"
  do
    result_8572e4b="$result_8572e4b$item$sep"
  done
}

# Put the value for the key in the map, replacing the current one if any. The entry is moved to the end of the map.
# Usage: mput [-v var] [-s separator] map key value
mput() {
  local var_name_67ed374=
  local sep_67ed374="$CH_US"
  OPTIND=1; while getopts v:s:-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (v) var_name_67ed374="$OPTARG";;
      (s|sep|separator) sep_67ed374="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))
  mput_7ab208c "$sep_67ed374" "$@"
  print_to "$var_name_67ed374" "$result_8572e4b"
}

# Usage: mget_998d303 separator map key
mget_998d303() {
  local sep="$1"
  local key="$3"
  local IFS="$sep"
  # shellcheck disable=SC2086
  set -- $2
  local i=0
  local n=$(($#/2))
  while test "$i" -lt "$n"
  do
    test "$1" = "$key" && result_8572e4b="$2" && return 0
    shift 2
    i=$((i+1))
  done
  return 1
}

# Get the value for the key in the map. Fail if the key is not found.
# Usage: mget [-v var] [-s separator] map key
mget() {
  local var_name_04dcfd8=
  local sep_04dcfd8="$CH_US"
  OPTIND=1; while getopts v:s:-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (v) var_name_04dcfd8="$OPTARG";;
      (s|sep|separator) sep_04dcfd8="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))
  mget_998d303 "$sep_04dcfd8" "$@" || return $?
  print_to "$var_name_04dcfd8" "$result_8572e4b"
}

# Usage: mkeys_293ed90 separator map
mkeys_293ed90() {
  local sep="$1"
  local IFS="$sep"
  # shellcheck disable=SC2086
  set -- $2
  local i=0
  local n=$(($#/2))
  result_8572e4b=
  while test "$i" -lt "$n"
  do
    result_8572e4b="$result_8572e4b$1$sep"
    shift 2
    i=$((i+1))
  done
}

# Get the keys of the map as a vector separated by the same separator.
# Usage: mkeys [-v var] [-s separator] map
mkeys() {
  local var_name_ffb775e=
  local sep_ffb775e="$CH_US"
  OPTIND=1; while getopts v:s:-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (v) var_name_ffb775e="$OPTARG";;
      (s|sep|separator) sep_ffb775e="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))
  mkeys_293ed90 "$sep_ffb775e" "$@"
  print_to "$var_name_ffb775e" "$result_8572e4b"
}

#endregion

# Demonstrate the functions above. Run when this file is executed directly.
collection() {
  local sep="#"
  local m=
  mput -v m -s"$sep" "$m" "key" "value"
  echo "$m"
  mput -v m -s"$sep" "$m" "key" "value  x  y${CH_LF}value${CH_TAB}z"
  echo "$m"
  local value
  mget -v value -s"$sep" "$m" "key"
  echo "80745a9 $value"
  mput -v m -s"$sep" "$m" "bar" "BAR"
  local keys
  mkeys -v keys -s"$sep" "$m"
  echo 759f2ba "$keys"
  local IFS="$sep"
  local arg
  for arg in $keys
  do
    echo "442f931 <$arg>"
  done
  unset IFS
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (collection.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  collection "$@"
fi
