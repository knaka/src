#!/usr/bin/env bash
set -- __MISE_TASKS_PROJECT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# Foo
task_foo() {
  printf "<%s>, <%s>" "$HEREDOC" "$APP_ENV"
}

# Update documentation files.
task_doc() {
  mdpp --in-place --allow-remote \
    README.md \
    DEVELOPMENT.md \
    CLAUDE.md \
    #nop
}
