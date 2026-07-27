# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3ae0529-false}" && return 0; sourced_3ae0529=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
cd "$3" || exit; shift 3

vw() {
  init_temp_dir
  local title="(stdin)"
  if test $# -ge 1
  then
    title="$(basename "$1") (RO)"
  fi
  local file_path="$TEMP_DIR"/"$title"
  cat "$@" >"$file_path"
  chmod 444 "$file_path"
  ed --block "$file_path"
}

case "${0##*/}" in
  (vw.sh|vw)
    set -o nounset -o errexit
    vw "$@"
    ;;
esac
