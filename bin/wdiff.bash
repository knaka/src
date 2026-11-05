#!/usr/bin/env bash
set -- _e46a3b5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# `delta --light --show-config` to show colors.

wdiff() {
  local word_diff_regex="[a-zA-Z0-9_]+"
  if is_macos
  then
    word_diff_regex="[a-zA-Z0-9_]+|[ぁ-ん]+|[ァ-ヶー]+|[一-龥々〇〆]+|."
  fi
  GIT_PAGER=less git \
    -c color.diff.old='normal #ffc0c0' \
    -c color.diff.new='normal #a0efa0' \
    diff \
    --no-index \
    --color-words \
    --word-diff-regex="$word_diff_regex" \
    "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 wdiff "$@"
fi
