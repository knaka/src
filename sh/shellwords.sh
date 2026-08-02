#!/usr/bin/env sh
set -- _8a2affe "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# 各言語にある “shellwords” 機能の元ネタは Perl 4 のころのスクリプトで、現 Text::ParseWords の “shellwords” かな。

shellwords() {
  local cmd='foo bar  hoge fuga x="aaa   bbb"'
  eval "set -- $cmd"
  printf "%s\n" "$@"
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\]}." in (shellwords.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  shellwords "$@"
fi
