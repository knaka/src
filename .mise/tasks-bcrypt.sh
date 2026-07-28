# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ _MISE_TASKS_BCRYPT_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # shpp:end_source

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.tasks-bcrypt.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  "$@"
fi
