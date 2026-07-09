#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 6416661 && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ./.lib "$@"
. ./utils.sh
shift 2
cd "$1" || exit 1; shift

# ==========================================================================
#region .env* file management

# Load environment variables from the specified file.
load_env_file() {
  if ! test -r "$1"
  then
    return 0
  fi
  local line
  local key
  local value
  while read -r line
  do
    key="${line%%=*}"
    if test -z "$key" || test "$key" = "$line"
    then
      continue
    fi
    value="$(eval "echo \"\${$key:=}\"")"
    # Do not overwrite an existing, previously set value.
    if test -n "$value"
    then
      continue
    fi
    eval "$line"
  done <"$1"
}

# Load environment variables from .env* files
load_dotenv() {
  first_call 8005f70 || return 0
  # Load the files in the order of priority.
  if test "${APP_ENV+set}" = set
  then
    load_env_file "$PROJECT_DIR"/.env."$APP_ENV".session
    load_env_file "$PROJECT_DIR"/.env."$APP_ENV".local
  fi
  if test "${APP_ENV+set}" != set || test "${APP_ENV}" != "test"
  then
    load_env_file "$PROJECT_DIR"/.env.session
    load_env_file "$PROJECT_DIR"/.env.local
  fi
  if test "${APP_ENV+set}" = set
  then
    load_env_file "$PROJECT_DIR"/.env."$APP_ENV"
  fi
  # shellcheck disable=SC1091
  load_env_file "$PROJECT_DIR"/.env
}

#endregion
