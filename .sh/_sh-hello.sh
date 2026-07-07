#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5e61dcb-false}" && return 0; sourced_5e61dcb=true

. ./_foo.lib.sh

hello() {
  local name="World"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (name) name="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  local os
  if is_windows
  then
    os=Windows
  elif is_macos
  then
    os=MacOS
  elif is_linux
  then
    os=Linux
  else
    os=Unknown
  fi

  printf "Hello, %s, I am %s!\n" "$name" "$os"
}

hello "$@"
foo
