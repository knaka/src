#!/usr/bin/env bash
set -- __MISE_TASKS_PROJECT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# Foo
task_foo() {
  printf "<%s>, <%s>\n" "$HEREDOC" "$APP_ENV"
  echo 6aa11dd "$@"
  echo d468476 "$MISE_BIN"
}

# Update documentation files.
task_doc() {
  mdpp --in-place --allow-remote \
    README.md \
    DEVELOPMENT.md \
    CLAUDE.md \
    #nop
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

# Run Arch Linux Docker container.
task_docker__archlinux__run() {
  run_once task_docker__start__temp
  docker run --platform linux/amd64 --rm -it -v "$PWD:/work" "$(docker build  --platform linux/amd64 --quiet --file archlinux.Dockerfile .)" "$@"
}
