#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 1c7f787 && return 0

sort_ignoring_comment() {
  sed -Ee 's/^([[:blank:]]*)(#[[:blank:]]+)(.*)$/\1\3 _aa3700a_ \2/' \
  | sort \
  | sed -Ee 's/^([[:blank:]]*)(.*) _aa3700a_ (.*)/\1\3\2/' \
  #nop
}

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ sort_ignoring_comment || _ sort-ignoring-comment
then
  set -o nounset -o errexit
  sort_ignoring_comment "$@"
fi
