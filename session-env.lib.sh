# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_171f445-false}" && return 0; sourced_171f445=true

clear_session_env() {
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${RUNNER_PID+set}" = set || MISE_PID=x
    rm -f "$TMPDIR"/session-envs-"$MISE_PID".sh
  else
    echo "Unknown task runner." >&2
    return 1
  fi
}

add_session_env() {
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${MISE_PID+set}" = set || MISE_PID=x
    local key="$1"
    local value="$2"
    echo "export $key=$value" >>"$TMPDIR"/session-envs-"$MISE_PID".sh
  else
    echo "Unknown task runner." >&2
    return 1
  fi
}

restore_session_env() {
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${MISE_PID+set}" = set || MISE_PID=x
    # shellcheck disable=SC1090
    . "$TMPDIR"/session-envs-"$MISE_PID".sh
  else
    echo "Unknown task runner." >&2
    return 1
  fi
}
