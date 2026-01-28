#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3fee958-false}" && return 0; sourced_3fee958=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

# Releases · knaka/tblcalc https://github.com/knaka/tblcalc/releases
tblcalc_version_e276172="v0.9.4"

tblcalc() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="tblcalc" \
    --ver="$tblcalc_version_e276172" \
    --os-map="$goos_camel_map" \
    --arch-map="x86_64 x86_64 aarch64 arm64 " \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/knaka/tblcalc/releases/download/${ver}/tblcalc_${os}_${arch}${ext}' \
    -- \
    "$@"
}

case "${0##*/}" in
  (tblcalc.sh|tblcalc)
    set -o nounset -o errexit
    tblcalc "$@"
    ;;
esac
