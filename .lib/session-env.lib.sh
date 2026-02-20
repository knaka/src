# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_171f445-false}" && return 0; sourced_171f445=true

init_session() {
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${MISE_PID+set}" = set || MISE_PID=x
    rm -f "${TMP-$TMPDIR}"/session-envs-"$MISE_PID".sh
  else
    echo "Unknown task runner." >&2
    return 1
  fi
}

save_session_var() {
  local key="$1"
  local value="$2"
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${MISE_PID+set}" = set || MISE_PID=x
    echo "export $key=$value" >>"${TMP-$TMPDIR}"/session-envs-"$MISE_PID".sh
  else
    echo "Unknown task runner." >&2
    return 1
  fi
}

load_session_vars() {
  if test "${MISE_CONFIG_ROOT+set}" = set
  then
    test "${MISE_PID+set}" = set || MISE_PID=x
    if test -r "${TMP-$TMPDIR}"/session-envs-"$MISE_PID".sh
    then
      # shellcheck disable=SC1090
      . "${TMP-$TMPDIR}"/session-envs-"$MISE_PID".sh
    fi
  else
    echo "Unknown task runner." >&2
    return 1
  fi
}
