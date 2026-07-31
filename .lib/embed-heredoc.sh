#!/usr/bin/env sh
set -- __LIB_EMBED_HEREDOC_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
script_4f605d1="$PWD"/embed-heredoc.awk
cd "$3" || exit; shift 3 # /shpp:sources

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
