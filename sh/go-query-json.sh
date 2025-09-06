#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ce97d11-false}" && return 0; sourced_ce97d11=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./go.lib.sh
cd "$1"; shift 2

. ./task.sh 

GO111MODULE=on go list -m --json "$@"
