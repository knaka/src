#!/bin/sh
set -o nounset -o errexit

test "${guard_490b7a1+set}" = set && return 0; guard_490b7a1=x

array_head() (
  arr="$1"
  test -z "$arr" && return 1
  IFS="$2"
  # shellcheck disable=SC2086
  set -- $arr
  echo "$1"
)

array_tail() (
  arr="$1"
  test -z "$arr" && return 1
  IFS="$2"
  # shellcheck disable=SC2086
  set -- $arr
  shift
  echo "$*"
)

array_length() (
  arr="$1"
  IFS="$2"
  # shellcheck disable=SC2086
  set -- $arr
  echo "$#"
)

array_append() (
  arr="$1"
  shift
  IFS="$1"
  shift
  (
    test -n "$arr" && echo "$arr"
    printf "%s\n" "$@" | while read -r arr2
    do
      # shellcheck disable=SC2086
      printf "%s\n" $arr2
    done
  ) | paste -sd "$IFS" -
)

array_prepend() (
  arr="$1"
  shift
  IFS="$1"
  shift
  (
    printf "%s\n" "$@" | while read -r arr2
    do
      # shellcheck disable=SC2086
      printf "%s\n" $arr2
    done
    test -n "$arr" && echo "$arr"
  ) | paste -sd "$IFS" -
)

array_at() (
  arr="$1"
  shift
  IFS="$1"
  shift
  i=0
  for item in $arr
  do
    if test "$i" -eq "$1"
    then
      echo "$item"
      return
    fi
    i=$((i + 1))
  done
  return 1
)

array_map() (
  reads_stdin=false
  arr="$1"
  shift
  if test "$arr" = "-"
  then
    reads_stdin=true
    arr="$(cat)"
  fi
  IFS="$1"
  shift
  should_replace=false
  for arg in "$@"
  do
    if test "$arg" = "_" || test "$arg" = "it"
    then
      should_replace=true
    fi
  done
  delim=
  for i in $arr
  do
    printf "%s" "$delim"
    if $reads_stdin
    then
      printf "%s" "$(printf "%s" "$i" | "$@")"
    elif $should_replace
    then
      (
        for arg in "$@"
        do
          if test "$arg" = "_" || test "$arg" = "it"
          then
            # shellcheck disable=SC2016
            arg='$i'
          fi
          set -- "$@" "$arg"
          shift
        done
        printf "%s" "$("$@")"
      )
    else
      printf "%s" "$("$@" "$i")"
    fi
    delim="$IFS"
  done
)

array_filter() (
  arr="$1"
  shift
  IFS="$1"
  shift
  should_replace=false
  for arg in "$@"
  do
    if test "$arg" = "_"
    then
      should_replace=true
    fi
  done
  delim=
  for i in $arr
  do
    if $should_replace
    then
      if ! (
        for arg in "$@"
        do
          if test "$arg" = "_"
          then
            # shellcheck disable=SC2016
            arg="$i"
          fi
          set -- "$@" "$arg"
          shift
        done
        "$@" 
      )
      then
        continue
      fi
    elif ! "$@" "$i"
    then
      continue
    fi
    printf "%s%s" "$delim" "$i"
    delim="$IFS"
  done
)

array_reduce() (
  arr="$1"
  shift
  IFS="$1"
  shift
  acc="$1"
  shift
  has_place_holder=false
  for arg in "$@"
  do
    if test "$arg" = "_"
    then
      has_place_holder=true
    fi
  done
  for i in $arr
  do
    if $has_place_holder
    then
      acc="$(
        first=true
        for arg in "$@"
        do
          if test "$arg" = "_"
          then
            if $first
            then
              arg="$acc"
              first=false
            else
              arg="$i"
            fi
          fi
          set -- "$@" "$arg"
          shift
        done
        "$@"
      )"
    else
      acc="$("$@" "$acc" "$i")"
    fi
  done
  echo "$acc"
)

array_reverse() (
  arr="$1"
  IFS="$2"
  # shellcheck disable=SC2086
  set -- $arr
  i=$#
  delim=
  while test "$i" -gt 0
  do
    eval printf "%s%s" "$delim" "\$$i"
    delim="$IFS"
    i=$((i - 1))
  done
)

array_contains() (
  arr="$1"
  shift
  IFS="$1"
  shift
  item="$1"
  shift
  for i in $arr
  do
    if test "$i" = "$item"
    then
      return 0
    fi
  done
  return 1
)

array_each() (
  reads_stdin=false
  arr="$1"
  shift
  if test "$arr" = "-"
  then
    reads_stdin=true
    arr="$(cat)"
  fi
  IFS="$1"
  shift
  should_replace=false
  for arg in "$@"
  do
    if test "$arg" = "_" || test "$arg" = "it"
    then
      should_replace=true
    fi
  done
  # shellcheck disable=SC2086
  printf "%s\n" $arr | while read -r i
  do
    if $reads_stdin
    then
      echo "$i" | "$@"
    elif $should_replace
    then
      (
        for arg in "$@"
        do
          if test "$arg" = "_" || test "$arg" = "it"
          then
            arg="$i"
          fi
          set -- "$@" "$arg"
          shift
        done
        "$@"
      )
    else
      "$@" "$i"
    fi
  done
)

array_sort() (
  arr="$1"
  shift
  IFS="$1"
  shift
  # shellcheck disable=SC2086
  printf "%s\n" $arr | if test "$#" -eq 0; then sort; else "$@"; fi | paste -sd "$IFS" -
)

. ./task.sh

if is_bsd
then
  alias shuf='sort -R'
fi

array_shuffle() (
  arr="$1"
  shift
  IFS="$1"
  shift
  # shellcheck disable=SC2086
  printf "%s\n" $arr | shuf | paste -sd "$IFS" -
)
