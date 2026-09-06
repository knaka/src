#!/usr/bin/env bash
set -- _4227882 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# [password] Create hash from password with bcrypt.
#MISE tools={"uv"="0.10"}
task_bcrypt__hash() {
  tail_exec mise exec uv -- uv tool run --from "bcrypt" python3 -c 'import sys, bcrypt; print(bcrypt.hashpw(sys.argv[1].encode(), bcrypt.gensalt()).decode())' "$1"
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

  tail_exec mise exec uv -- uv tool run --from "bcrypt" python3 -c 'import sys, bcrypt; sys.exit(0 if bcrypt.checkpw(sys.argv[1].encode(), sys.argv[2].encode()) else 1)' "$password" "$hash" >/dev/null 2>&1
}
