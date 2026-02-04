#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4b40a17-false}" && return 0; sourced_4b40a17=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

set -o nounset -o errexit

# Basename without extension
base="${0##*/}"
base="${base##*\\}"
base="${base%.sh}"

go_ver="1.25"
node_ver="24"

case "$base" in
  (go) mise exec go@"$go_ver" -- go "$@";;
  (gofmt) mise exec go@"$go_ver" -- gofmt "$@";;
  # (jmespath) mise jmespath -- jmespath "$@";;
  (jq) jq "$@";;
  (lua) mise exec lua -- lua "$@";;
  (mise) mise "$@";;
  (node) mise exec node@"$node_ver" -- node "$@";;
  (npm) mise exec node@"$node_ver" -- npm "$@";;
  (npx) mise exec node@"$node_ver" -- npx "$@";;
  (*)
    echo e594d12: "$base" >&2
    exit 1
esac
