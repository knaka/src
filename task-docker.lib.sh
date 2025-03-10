#!/bin/sh
test "${guard_2c50c57+set}" = set && return 0; guard_2c50c57=x

# Docker task library.

. ./task.sh

subcmd_docker() ( # Run a Docker command.
  if ! type docker > /dev/null 2>&1
  then
    echo "Docker is not installed. Exiting." >&2
    exit 1
  fi
  if ! docker version > /dev/null 2>&1
  then
    echo "Docker is not availabe. Exiting." >&2
    exit 1
  fi
  docker "$@"
)

task_docker__status() { # Show the status of Docker.
  subcmd_docker info
}

task_docker__start() { # Start Docker.
  if task_docker__status >/dev/null 2>&1
  then
    echo "Docker is already running." >&2
    return 0
  fi
  echo "Docker is not running. Starting Docker." >&2
  # Restart Docker from command line - Docker Desktop - Docker Community Forums https://forums.docker.com/t/restart-docker-from-command-line/9420/9
  if is_macos
  then
    # open --background -a Docker
    open -a "Docker"
    while true
    do
      sleep 1
      if task_docker__status >/dev/null 2>&1
      then
        echo "Docker has started." >&2
        break
      fi
    done
  else
    echo "Not implemented."
    return 1
  fi
}

task_docker__start__temp() { # Start Docker temporarily. If Docker is already running, do nothing when the task runner exits.
  if task_docker__status >/dev/null 2>&1
  then
    echo "Docker is already running. Using the existing Docker." >&2
  else
    task_docker__start
    chaintrap task_docker__stop EXIT
  fi
}

task_docker__stop() { # Stop Docker.
  if ! task_docker__status >/dev/null 2>&1
  then
    echo "Docker is not running." >&2
    return 0
  fi
  echo "Docker is running. Stopping Docker." >&2
  # Restart Docker from command line - Docker Desktop - Docker Community Forums https://forums.docker.com/t/restart-docker-from-command-line/9420/9
  if is_macos
  then
    # osascript -e 'quit app "Docker"'
    # osascript -e 'quit app "Docker Desktop"'
    killall "Docker Desktop"
  else
    echo "Not implemented."
    return 1
  fi
}
