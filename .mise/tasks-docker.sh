#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __MISE_TASKS_DOCKER_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

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
    run_once task_docker__start
    add_exit_handler task_docker__stop
  fi
}

# Run Debian Docker container.
task_docker__debian__run() {
  run_once task_docker__start__temp
  docker run --rm -it -v "$PWD:/work" "$(docker build --quiet --file debian.Dockerfile .)" "$@"
}

# Run BusyBox Docker container.
task_docker__busybox__run() {
  run_once task_docker__start__temp
  docker run --rm -it -v "$PWD:/work" "$(docker build --quiet --file busybox.Dockerfile .)" "$@"
}
