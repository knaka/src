# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_TEST_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

readonly RC_TEST_SKIPPED=10

skip() {
  return "$RC_TEST_SKIPPED"
}

skip_if() {
  if "$@"
  then
    return "$RC_TEST_SKIPPED"
  fi
}

skip_unless() {
  if ! "$@"
  then
    return "$RC_TEST_SKIPPED"
  fi
}
