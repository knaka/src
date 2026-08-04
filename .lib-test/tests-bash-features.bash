#!/usr/bin/env bash
set -- __LIB_TEST_TESTS_BASH_FEATURES_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/assert.sh
. ../.lib/test.sh
popd >/dev/null || exit

qux_b8af6e1() {
  local retcmds="trap - RETURN"
  trap 'eval "$retcmds"' RETURN
  retcmds="echo -n QUX,; $retcmds"
  echo -n qux_b8af6e1,
}

baz_a1bd4c5() {
  local retcmds="trap - RETURN"
  trap 'eval "$retcmds"' RETURN
  retcmds="echo -n BAZ,; $retcmds"
  echo -n baz_a1bd4c5,
}

bar_40d5ce3() {
  echo -n bar_40d5ce3,
  baz_a1bd4c5
  qux_b8af6e1
}

foo_9faf116() {
  local retcmds="trap - RETURN"
  trap 'eval "$retcmds"' RETURN
  retcmds="echo -n FOO,; $retcmds"
  echo -n foo_9faf116,
  bar_40d5ce3
}

# `trap - RETURN` appears to behave differently from other signals: it gets reset to the RETURN handler that was stacked for the calling function.
# — Save and restore bash RETURN traps within functions - Unix & Linux Stack Exchange https://unix.stackexchange.com/questions/804341/save-and-restore-bash-return-traps-within-functions

test_defer() {
  # On Brush shell, `RETURN` trap is not implemented yet. (2026-08-04)
  # brush/docs/reference/compatibility.md at main · reubeno/brush https://github.com/reubeno/brush/blob/main/docs/reference/compatibility.md
  skip_if is_brush

  assert_eq \
    "foo_9faf116,bar_40d5ce3,baz_a1bd4c5,BAZ,qux_b8af6e1,QUX,FOO,main" \
    "$(foo_9faf116; echo -n main)"
}
