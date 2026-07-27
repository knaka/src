#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 5f5f68e && return 0

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@"
script_4f605d1="$PWD"/embed-heredoc.awk
cd "$3" || exit; shift 3

embed_heredoc_sub() {
  local file="$1"
  cd "$(dirname "$file")" || return 1
  awk -f "$script_4f605d1" <"$(basename "$file")"
  cd "$OLDPWD" || return 1
}

embed_heredoc() {
  test $# = 0 && return 0

  init_temp_dir
  local path
  local temp_path="$TEMP_DIR/14a4092"
  for path in "$@"
  do
    embed_heredoc_sub "$path" >"$temp_path" 
    if test -s "$temp_path" && cmp -s "$path" "$temp_path"
    then
      echo "\"$path\" is up to date." >&2
    else
      cat "$temp_path" >"$path"
      echo "Wrote \"$path\"." >&2
    fi
  done
}
