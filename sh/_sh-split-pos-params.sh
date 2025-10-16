#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_40e9767-false}" && return 0; sourced_40e9767=true

foo() {
  local i=1 isep
  while test "$i" -le "$#"
  do
    if test "$1" = --
    then
      isep=$i
      (
        shift $(($#-isep+1))
        echo Call a command with "$@"
      ) || return 1
    fi
    set -- "$@" "$1"
    shift
    i=$((i+1))
  done
  shift "$isep"
  echo Call the other command with "$@"
}

foo 123 456 789 -- hoge fuga

echo

bar() {
  local arg
  local separated=false
  local first=true
  for arg in "$@" --
  do
    "$first" && set -- && first=false
    if test "$arg" = --
    then
      "$separated" && break
      separated=true
      echo Call a command with "$@"
      set --
      continue
    fi
    set -- "$@" "$arg"
  done
  echo Call the other command with "$@"
}

bar 123 456 789 -- hoge fuga
echo
bar 123 456 789 --
echo
bar 123 456 789
echo
bar -- hoge fuga
echo
bar
echo

# doit2() {
#   if test "${1+set}" = set && test "$1" = prep
#   then
#     shift
#     local i=1
#     while test "$i" -le "$#"
#     do
#       test "$1" = -- && shift "$i" && break
#       set -- "$@" "$1"
#       shift
#     done
#     echo ddfd9e8 "$@"
#     return 0
#   fi
#   doit2 prep "$@"

# }

# foo() {
#   local i=1
#   while test "$i" -le "$#"
#   do
#     test "$1" = -- && shift $((i+1)) && break
#     set -- "$@" "$1"
#     shift
#     i=$((i+1))
#   done
#   echo d0: "$@"
# }

# bar() {
#   shift 3
#   echo d1: "$@"
# }

# baz() {
#   local i=1
#   while test "$i" -le "$#"
#   do
#     eval echo d: "\$$i"
#     i=$((i+1))
#   done
# }

# foo abc xyz -- hoge fuga hare
# foo aaa bbb ccc
# bar abc xyz -- hoge fuga hare
# baz abc xyz -- hoge fuga hare
