#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5ab2f18-false}" && return 0; sourced_5ab2f18=true

set -o nounset -o errexit

on_exit() {
    echo "error happened!"
}
trap on_exit EXIT

echo "OK so far"
false
echo "this line should not execute"
