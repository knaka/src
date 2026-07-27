# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_eaf97e4-false}" && return 0; sourced_eaf97e4=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@"
. ./utils.sh
is_mise || . ./commands.sh
script_902b082="$(realpath ./embed-script.py)"
cd "$3" || exit; shift 3

# This function is tested, do not inlined.
embed_minified_sub() {
  # -u     : force the stdout and stderr streams to be unbuffered;
  #          this option has no effect on stdin; also PYTHONUNBUFFERED=x
  python -u "$script_902b082" "$1"
}

# Embeds minified file contents into shell script files in-place.
# Processes files containing #EMBED directives and replaces the content
# between single quotes with the minified contents of the referenced file.
# Files are only updated if the content actually changes.
embed_minified() {
  test $# = 0 && return 0

  init_temp_dir
  local path
  local temp_path="$TEMP_DIR/2163b17"
  for path in "$@"
  do
    embed_minified_sub "$path" >"$temp_path" 
    if test -s "$temp_path" && cmp -s "$path" "$temp_path"
    then
      echo "\"$path\" is up to date." >&2
    else
      cat "$temp_path" >"$path"
      echo "Wrote \"$path\"." >&2
    fi
  done
}
