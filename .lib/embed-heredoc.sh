#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 5f5f68e && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
shift 2
script_4f605d1="$PWD"/embed-heredoc.awk
cd "$1" || exit 1; shift

embed_heredoc_sub() {
  local file="$1"
  cd "$(dirname "$file")" || return 1
  awk -f "$script_4f605d1" <"$(basename "$file")"
  cd "$OLDPWD" || return 1
}

embed_heredoc() {
  test $# = 0 && return 0

  register_temp_cleanup
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
