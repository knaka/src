# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f8dde75-false}" && return 0; sourced_f8dde75=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

# Initializes the session by clearing any previously saved session variables.
# This should be called at the start of a task chain to ensure a clean state.
init_session() {
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${MISE_PID+set}" = set || MISE_PID=x
    rm -f "${TMP-$TMPDIR}"/session-vars-"$MISE_PID".sh
  else
    echo "Unknown task runner." >&2
    return 1
  fi
}

# Saves a variable to the session file for sharing between tasks.
# Usage: save_session_var KEY VALUE
save_session_var() {
  local key="$1"
  local value="$2"
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${MISE_PID+set}" = set || MISE_PID=x
    echo "export $key=$value" >>"${TMP-$TMPDIR}"/session-vars-"$MISE_PID".sh
  else
    echo "Unknown task runner." >&2
    return 1
  fi
}

# Loads all saved session variables into the current shell environment.
# This sources the session file, making all saved variables available.
init_task() {
  first_call 89c298d || return 0
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${MISE_PID+set}" = set || MISE_PID=x
    if test -r "${TMP-$TMPDIR}"/session-vars-"$MISE_PID".sh
    then
      # shellcheck disable=SC1090
      . "${TMP-$TMPDIR}"/session-vars-"$MISE_PID".sh
    fi
  else
    echo "Unknown task runner." >&2
    return 1
  fi
  load_dotenv
}

# Clears the session environment.
#MISE hide=true
task_session__init() {
  init_session
}

# Ensures the application environment variable $APP_ENV is set.
#MISE hide=true
#MISE depends=["session:init"]
#MISE tools={"gum"="0.17.0"}
task_appenv__ensure() {
  APP_ENVS="${APP_ENVS-development,staging,production}"
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
    local IFS=,
    # shellcheck disable=SC2086
    # shellcheck disable=SC2153
    set -- $APP_ENVS
    if test $# -eq 1
    then
      APP_ENV="$1"
    else
      APP_ENV="$(
        gum choose --header "Application Environment (\$APP_ENV):" "$@"
      )"
    fi
  fi
  save_session_var "APP_ENV" "$APP_ENV"
}

# Confirms a critical operation.
#MISE hide=true
#MISE depends=["appenv:ensure"]
task_critical__confirm() {
  init_task
  local IFS=,
  # shellcheck disable=SC2086
  set -- ${CRITICAL_APP_ENVS-}
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
  (tasks-session.sh)
    set -o nounset -o errexit
    "$@"
    ;;
esac
