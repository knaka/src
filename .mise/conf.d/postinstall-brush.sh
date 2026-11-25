#!/usr/bin/env sh
set -- __CONFIG_MISE_CONF_D_POSTINSTALL_BRUSH_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

foo_a2fe1ad() {
  pwd
  echo "FOO" "$FOO"
  echo "MISE_TOOL_INSTALL_PATH" "$MISE_TOOL_INSTALL_PATH"
  echo "MISE_TOOL_NAME" "$MISE_TOOL_NAME"
  echo "MISE_TOOL_VERSION" "$MISE_TOOL_VERSION"
  echo
  set
}

set -o nounset -o errexit
foo_a2fe1ad "$@" >/tmp/tmp.log
