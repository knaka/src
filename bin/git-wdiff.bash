#!/usr/bin/env bash
set -- _BIN_GIT_WDIFF_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# $ delta --light --show-config | grep minus-emph-style
#     minus-emph-style              = normal "#ffc0c0"
# $ delta --light --show-config | grep plus-emph-style
#     plus-emph-style               = syntax "#a0efa0"
readonly color_diff_old="normal #ffc0c0"
readonly color_diff_new="normal #a0efa0"

git_wdiff() {
  local locale=
  local wdiff_re
  if is_macos
  then
    wdiff_re="[a-zA-Z0-9_]+|[ぁ-ん]+|[ァ-ヶー]+|[一-龥々〆〇]+|[^[:space:]]"
  elif is_linux
  then
    # マルチバイト文字としても Unicode 文字（`\u...`）も書けないので、UTF-8 のバイト列の正規表現であらわす。
    locale="LC_ALL=C"
    # ひらがな U+3041-3093
    local re_hira=$'\xe3(\x81[\x81-\xbf]|\x82[\x80-\x93])'
    # カタカナ U+30A1-30F6 と長音符 ー
    local re_kata=$'\xe3(\x82[\xa1-\xbf]|\x83[\x80-\xb6]|\x83\xbc)'
    # 漢字 U+4000-9FFF と 々〆〇
    local re_kanji=$'[\xe4-\xe9][\x80-\xbf][\x80-\xbf]|\xe3\x80[\x85-\x87]'
    # 上記以外の ASCII 記号と、その他のマルチバイト文字1文字
    local re_other=$'[!-~]|[\xc0-\xff][\x80-\xbf]*'
    wdiff_re="[a-zA-Z0-9_]+|(${re_hira})+|(${re_kata})+|(${re_kanji})+|${re_other}"
  else
    echo Not implemented yet. >&2
    exit 1
  fi
  env \
    $locale \
    LESSCHARSET="utf-8" \
    GIT_PAGER=less \
    git \
    -c color.diff.old="$color_diff_old" \
    -c color.diff.new="$color_diff_new" \
    diff \
    --color-words \
    --word-diff-regex="$wdiff_re" \
    "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 git_wdiff "$@"
fi
