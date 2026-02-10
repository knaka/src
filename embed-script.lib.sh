# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_eaf97e4-false}" && return 0; sourced_eaf97e4=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR . "$@"
. ./task.sh
. ./tools.lib.sh
# script_902b082="$(canon_path ./embed.pl)"
script_902b082="$(canon_path ./embed.py)"
shift 2
cd "$1" || exit 1; shift

embed_minified_sub() {
  # perl "$script_902b082" "$path"
  python3 "$script_902b082" "$1"
}

# Embeds minified file contents into shell script files in-place.
# Processes files containing #EMBED directives and replaces the content
# between single quotes with the minified contents of the referenced file.
# Files are only updated if the content actually changes.
embed_minified() {
  if test $# = 0
  then
    echo "Usage: embed_minified <file>..." >&2
    return 1
  fi

  register_temp_cleanup
  local path
  local temp_path="$TEMP_DIR/2163b17"
  for path in "$@"
  do
    embed_minified_sub "$path" >"$temp_path" 
    if test -s "$temp_path" && ! cmp -s "$path" "$temp_path"
    then
      cat "$temp_path" >"$path"
    fi
  done
}
