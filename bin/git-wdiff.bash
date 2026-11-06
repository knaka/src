#!/usr/bin/env bash
set -- _BIN_GIT_WDIFF_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Show a word-level `git diff` that also splits Japanese text by character class, in the same colors as delta(1), chosen according to the terminal background. Arguments are passed to `git diff`.

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./is-light-mode.bash
popd >/dev/null || exit

# $ delta --light --show-config | grep minus-emph-style
#     minus-emph-style              = normal "#ffc0c0"
# $ delta --light --show-config | grep plus-emph-style
#     plus-emph-style               = syntax "#a0efa0"
readonly color_diff_old_light="normal #ffc0c0"
readonly color_diff_new_light="normal #a0efa0"

# $ delta --dark --show-config | grep minus-emph-style
#     minus-emph-style              = normal "#901011"
# $ delta --dark --show-config | grep plus-emph-style
#     plus-emph-style               = syntax "#006000"
readonly color_diff_old_dark="normal #901011"
readonly color_diff_new_dark="normal #006000"

# Check if the language of the current locale is Japanese.
is_ja_locale() {
  case "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" in
    (ja|ja[_.@]*) return 0;;
  esac
  return 1
}

git_wdiff() {
  local detect_dark_light=auto
  local i=$#
  while test "$i" -gt 0
  do
    case "$1" in
      (--detect-dark-light=*) detect_dark_light="${1#*=}";;
      (*) set -- "$@" "$1";;
    esac
    shift
    i=$((i - 1))
  done

  local locale=
  local wdiff_re="[a-zA-Z0-9_]+|[^[:space:]]"
  if is_macos
  then
    if is_ja_locale
    then
      wdiff_re="[a-zA-Z0-9_]+|[ぁ-ん]+|[ァ-ヶー]+|[一-龥々〆〇]+|[^[:space:]]"
    fi
  elif is_linux
  then
    if is_ja_locale
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
    fi
  else
    echo Not implemented yet. >&2
    exit 1
  fi
  local color_diff_old="$color_diff_old_dark"
  local color_diff_new="$color_diff_new_dark"
  local should_query=false
  case "$detect_dark_light" in
    (auto) test -t 1 && should_query=true;;
    (always) should_query=true;;
    (never) ;;
    (*) echo "$0: invalid value for --detect-dark-light -- $detect_dark_light" >&2; return 1;;
  esac
  if "$should_query" && is_light_mode
  then
    color_diff_old="$color_diff_old_light"
    color_diff_new="$color_diff_new_light"
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
