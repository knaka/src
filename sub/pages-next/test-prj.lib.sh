#!/bin/sh
test "${guard_11b0346+set}" = set && return 0; guard_11b0346=x
set -o nounset -o errexit

. ../assert.lib.sh
. ./task.sh

rewrite_args() (
  usv_args="$(echo "$1" | sed -E -e "s/, */${us}/g")"
  delim=
  push_ifs
  IFS="${us}"
  for arg in $usv_args
  do
    printf '%stypeof %s === "undefined"? null: %s' "$delim" "$arg" "$arg"
    delim=", "
  done
  pop_ifs
)

rewrite_args2() (
  echo "$1," | sed -E -e 's/([^,]+), */typeof \1 === "undefined"? null: \1, /g' -e 's/, *$//'
)

test_eval() (
  set +o errexit

  assert_eq 'typeof A === "undefined"? null: A, typeof B === "undefined"? null: B' "$(rewrite_args "A, B")"
  assert_eq 'typeof args.nullableId === "undefined"? null: args.nullableId, typeof args.nullableUsername === "undefined"? null: args.nullableUsername' "$(rewrite_args2 'args.nullableId, args.nullableUsername')"
)
