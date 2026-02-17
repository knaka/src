# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f8dde75-false}" && return 0; sourced_f8dde75=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/session-env.lib.sh
shift 2
cd "$1" || exit 1; shift 2

# Clears the session environment.
#MISE hide=true
task_sessionenv__clear() {
  clear_session_env
}

choose_env() {
  local IFS=,
  # shellcheck disable=SC2086
  # shellcheck disable=SC2153
  set -- $APP_ENVS
  gum choose --header "Application Environment (\$APP_ENV):" "$@"
}

# Ensures the application environment variable $APP_ENV is set.
#MISE hide=true
#MISE depends=["sessionenv:clear"]
task_appenv__ensure() {
  if test "${APP_ENV+set}" = set
  then
    case ",$APP_ENVS," in
      (*,"$APP_ENV",*) ;;
      (*)
        {
          echo "\"$APP_ENV\" is not a valid value for the \"\$APP_ENV\" variable. Available values are:"
          local IFS=,
          local env
          for env in $APP_ENVS
          do
            echo "  * $env"
          done
        } >&2
        return 1
        ;;
    esac
  else
    APP_ENV="$(choose_env)"
  fi
  add_session_env "APP_ENV" "$APP_ENV"
}

# Confirms a critical operation.
#MISE hide=true
#MISE depends=["appenv:ensure"]
task_critenv__confirm() {
  restore_session_env
  local IFS=,
  # shellcheck disable=SC2086
  set -- $CRITICAL_APP_ENVS
  local env
  for env in "$@"
  do
    if test "$APP_ENV" = "$env"
    then
      gum confirm --default=no \
        "You are performing a critical operation on the \"$APP_ENV\" environment. Proceed?"
      break
    fi
  done
}

case "${0##*/}" in
  (tasks-*)
    set -o nounset -o errexit
    "$@"
    ;;
esac
