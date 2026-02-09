# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_4c4cee6-}" = true && return 0; sourced_4c4cee6=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
shift 2
cd "$1" || exit 1; shift

# [password] Create hash from password with bcrypt
task_bcrypt__hash() {
  mise exec uv -- uv tool run --from "bcrypt" python3 -c 'import sys, bcrypt; print(bcrypt.hashpw(sys.argv[1].encode(), bcrypt.gensalt()).decode())' "$1" >/dev/null 2>&1
}

# [--password=<password> --hash=<hash>] Verify password against bcrypt hash
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
      (password) password=$OPTARG;;
      (hash) hash=$OPTARG;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  mise exec uv -- uv tool run --from "bcrypt" python3 -c 'import sys, bcrypt; sys.exit(0 if bcrypt.checkpw(sys.argv[1].encode(), sys.argv[2].encode()) else 1)' "$password" "$hash" "$1" >/dev/null 2>&1
}
