#!/bin/sh
# shellcheck disable=SC3043
test "${guard_a8ac234+set}" = set && return 0; guard_a8ac234=x
set -o nounset -o errexit

. ./task.sh
. ./task-docker.lib.sh

repl_usage() {
  echo "exit: Exit the program."
}

task_repl() { # Start a REPL.
  while true
  do
    printf "> "
    IFS= read -r line
    case "$line" in
      (exit) break;;
      ("") repl_usage;;
      (*)
        backup_shell_flags
        set +o errexit
        eval "$line"
        echo "exit status: $?" >&2
        restore_shell_flags
        ;;
    esac
  done
}

subcmd_debian__run() { # Run a command in a Debian Docker container.
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file debian.Dockerfile .)" "$@"
}

task_debian__test() { # Run tests in a Debian Docker container.
  subcmd_debian__run ./task test
}

subcmd_busybox__run() { # Run a command in a BusyBox Docker container.
  task_docker__start__temp
  subcmd_docker run --rm -it -v "$(pwd):/work" "$(subcmd_docker build --quiet --file busybox.Dockerfile .)" "$@"
}

task_busybox__test() { # Run tests in a BusyBox Docker container.
  subcmd_busybox__run ./task test
}

task_key() { # Read a key press and show its code.
  echo "Press a key."
  local key
  key="$(get_key)"
  printf "Key %02x pressed.\n" "'$key"
}

task_nop() { # Do nothing.
  :
}

subcmd_diff() { # Detect differences from the directory.
  local target_dir="${1}"
  find "${target_dir}" -type f -name "task*.sh" -maxdepth 1 \
  | while IFS= read -r theirs
  do
    base="$(basename "${theirs}")"
    case "${base}" in
      (task-prj*.sh) continue;;
    esac
    ours="$(find . -type f -name "${base}" -maxdepth 2 | head -n 1)"
    if test -z "${ours}"
    then
      continue
    fi
    if ! diff -q "${ours}" "${theirs}"
    then
      echo "Different: ${ours} ${theirs}"
      diff -u "${ours}" "${theirs}" || :
    fi
  done
}
