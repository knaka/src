#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 25fddd3 && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift

# Show the status of Docker.
task_docker__status() {
  docker info
}

# Start Docker.
task_docker__start() {
  if task_docker__status >/dev/null 2>&1
  then
    echo "Docker is already running." >&2
    return 0
  fi
  echo "Docker is not running. Starting Docker." >&2
  # Restart Docker from command line - Docker Desktop - Docker Community Forums https://forums.docker.com/t/restart-docker-from-command-line/9420/9
  if is_macos
  then
    open -a "Docker"
    while :
    do
      sleep 1
      if task_docker__status >/dev/null 2>&1
      then
        echo "Docker has started." >&2
        break
      fi
    done
  else
    echo "Not implemented." >&2
    return 1
  fi
}

# Stop Docker.
task_docker__stop() {
  if ! task_docker__status >/dev/null 2>&1
  then
    echo "Docker is not running." >&2
    return 0
  fi
  echo "Docker is running. Stopping Docker." >&2
  # Restart Docker from command line - Docker Desktop - Docker Community Forums https://forums.docker.com/t/restart-docker-from-command-line/9420/9
  if is_macos
  then
    killall "Docker Desktop"
  else
    echo "Not implemented." >&2
    return 1
  fi
}

# Start Docker service temporarily. If Docker is already running, do nothing when the task runner exits.
#MISE hide=true
task_docker__start__temp() {
  if task_docker__status >/dev/null 2>&1
  then
    echo "Docker is already running. Using the existing Docker." >&2
  else
    echo 2f783ed
    run_once task_docker__start
    prepend_cleanup task_docker__stop
  fi
}

# Run Debian Docker container.
task_docker__debian__exec() {
  task_docker__start__temp
  docker run --rm -it -v "$PWD:/work" "$(docker build --quiet --file debian.Dockerfile .)" "$@"
}
