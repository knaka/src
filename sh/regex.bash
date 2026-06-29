# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 49be6b8 && return 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
popd >/dev/null || exit 1

regex() {
  local haystack="foo bar baz"

  # regex - Does bash support word boundary regular expressions? - Stack Overflow https://stackoverflow.com/questions/9792702/does-bash-support-word-boundary-regular-expressions
  [[ "$haystack" =~ bar ]] || return 1
  [[ "$haystack" =~ ba ]] || return 1
  [[ "$haystack" =~ ${lwb}ba${rwb} ]] && return 1
  [[ "$haystack" =~ ${lwb}bar${rwb} ]] || return 1
  [[ "$haystack" =~ ${lwb}barr${rwb} ]] && return 1
  :
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  regex "$@"
fi
