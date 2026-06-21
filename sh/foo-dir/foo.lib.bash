# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash

echo 000381c: "$_SOURCED", foo

pushd "${BASH_SOURCE[0]%/*}" >/dev/null || exit 1
. ./bar-dir/bar.lib.bash
. ./bar-dir/bar.lib.bash
popd >/dev/null || exit 1
