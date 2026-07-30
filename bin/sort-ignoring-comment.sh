#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_SORT_IGNORING_COMMENT_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

sort_ignoring_comment() {
  sed -Ee 's/^([[:blank:]]*)(#[[:blank:]]+)(.*)$/\1\3 _aa3700a_ \2/' \
  | sort \
  | sed -Ee 's/^([[:blank:]]*)(.*) _aa3700a_ (.*)/\1\3\2/' \
  #nop
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (sort-ignoring-comment.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  sort_ignoring_comment "$@"
fi
