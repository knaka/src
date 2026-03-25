#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a7b4d1a-false}" && return 0; sourced_a7b4d1a=true

set -o errexit -o nounset

. ./main.lib.sh

x="$(xd7660ef)"
test -n "$x"
