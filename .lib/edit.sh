# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_EDIT_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

extract_block() {
  local begin_marker="$1"
  local end_marker="$2"
  local file_path="$3"
  sed -n "/${begin_marker}/,/${end_marker}/p" "${file_path}"
}

exclude_block() {
  local begin_marker="$1"
  local end_marker="$2"
  local file_path="$3"
  sed "/${begin_marker}/,/${end_marker}/d" "${file_path}"
}

extract_before() {
  local marker="$1"
  local file_path="$2"
  sed -n "1,/${marker}/p" "${file_path}"
}

extract_after() {
  local marker="$1"
  local file_path="$2"
  sed -n "/${marker}/,\$p" "${file_path}"
}
