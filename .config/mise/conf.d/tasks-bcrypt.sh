# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_84cae10-false}" && return 0; sourced_84cae10=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

# [password] Create hash from password with bcrypt.
#MISE tools={"uv"="0.10"}
task_bcrypt__hash() {
  mise exec uv -- uv tool run --from "bcrypt" python3 -c 'import sys, bcrypt; print(bcrypt.hashpw(sys.argv[1].encode(), bcrypt.gensalt()).decode())' "$1"
}

# [--password=<password> --hash=<hash>] Verify password against bcrypt hash.
#MISE tools={"uv"="0.10"}
task_bcrypt__verify() {
  local password=
  local hash=
  OPTIND=1; while getopts _-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (password) password="$OPTARG";;
      (hash) hash="$OPTARG";;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  mise exec uv -- uv tool run --from "bcrypt" python3 -c 'import sys, bcrypt; sys.exit(0 if bcrypt.checkpw(sys.argv[1].encode(), sys.argv[2].encode()) else 1)' "$password" "$hash" >/dev/null 2>&1
}

case "${0##*/}" in
  (tasks-*)
    set -o nounset -o errexit
    "$@"
    ;;
esac
