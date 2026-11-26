#!/usr/bin/env bash
set -- __MISE_TASKS_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ./.lib/utils.sh
. ./.mise/tasks-docker.bash
popd >/dev/null || exit

# Update documentation files.
task_doc() {
  mdpp --in-place --allow-remote \
    ./README.md \
    ./DEVELOPMENT.md \
    ./CLAUDE.md \
    #nop
}

# Run Debian Docker container.
task_docker__debian__run() {
  run_once task_docker__start__temp
  docker run --rm -it -v "$PWD:/work" "$(docker build --quiet --file ./debian.Dockerfile .)" "$@"
}

# Run BusyBox Docker container.
task_docker__busybox__run() {
  run_once task_docker__start__temp
  docker run --rm -it -v "$PWD:/work" "$(docker build --quiet --file ./busybox.Dockerfile .)" "$@"
}

# Run Arch Linux Docker container.
task_docker__archlinux__run() {
  run_once task_docker__start__temp
  # Arch Linux officially supports only x86-64, so the official image is amd64 only and runs under emulation on arm64 hosts. "Currently we have official packages optimized for the x86-64 architecture." — Arch Linux https://archlinux.org/
  docker run --platform linux/amd64 --rm -it -v "$PWD:/work" "$(docker build  --platform linux/amd64 --quiet --file ./archlinux.Dockerfile .)" "$@"
}
