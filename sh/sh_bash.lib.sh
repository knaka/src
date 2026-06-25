#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ ae73814 && return 0

echo hello sh

if test "${BASH+set}" != set -o "${BASH##*/}" != bash
then
  # shellcheck disable=SC2317
  return 0 2>/dev/null || exit 0
fi

echo hello bash
