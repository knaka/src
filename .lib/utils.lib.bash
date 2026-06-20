# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
"${sourced_e76ec9d-false}" && return 0; sourced_e76ec9d=true

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./utils.lib.sh
popd >/dev/null || exit 1

bash_val=123
