# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a32832b-false}" && return 0; sourced_a32832b=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2

cd "$1" || exit 1; shift 2
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

task_docker__debian__exec() {
  task_docker__start__temp
  docker run --rm -it -v "$PWD:/work" "$(docker build --quiet --file debian.Dockerfile .)" "$@"
}

case "${0##*/}" in
  (tasks-*)
    set -o nounset -o errexit
    "$@"
    ;;
esac
