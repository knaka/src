#!/bin/sh
set -o nounset -o errexit

should_block=false

while getopts "bt:" opt
do
  case "$opt" in
    b) should_block=true;;
    *) exit 1;;
  esac
done
shift $((OPTIND-1))

if test "$ARG0BASE" = "edw"
then
  should_block=true
fi

if which code > /dev/null
then
  opts=
  if $should_block
  then
    opts="--wait $opts"
  fi
  arg="$1"
  if ! test -e "$arg"
  then
    printf "%s does not exist. Create? (y/N): " "$arg"
    read -r yn
    case "$yn" in
      [yY]*) ;;
      *) exit 0 ;;
    esac
    touch "$arg"
  elif test -d "$arg"
  then
    printf "%s is a directory. Open? (y/N): " "$arg"
    read -r yn
    case "$yn" in
      [yY]*) ;;
      *) exit 0 ;;
    esac
  fi
  # shellcheck disable=SC2086
  exec code $opts "$@"
fi
