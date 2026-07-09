# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_06877c8-false}" && return 0; sourced_06877c8=true

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit 1; shift 

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
