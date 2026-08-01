#!/usr/bin/env bash
set -- _8e6944f "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

baz() {
  local var="BAZ"
  # local retcmds=':'
  local retcmds='trap - RETURN'
  trap 'eval "$retcmds"' RETURN
  retcmds="echo Returning from baz \$var RETURN; $retcmds"
  echo Baz "$var"
}

bar() {
  local var="BAR"
  # # local retcmds=':'
  # local retcmds='trap - RETURN'
  # trap 'eval "$retcmds"' RETURN
  # retcmds="echo Returning from bar \$var RETURN; $retcmds"
  baz
  echo Bar "$var"
}

foo() {
  local var="FOO"
  local retcmds=':'
  local retcmds='trap - RETURN'
  trap 'eval "$retcmds"' RETURN
  retcmds="echo Returning from foo \$var RETURN; $retcmds"
  bar
  echo Foo "$var"
}

trap_return() {
  # local var="MAIN"
  # local retcmds=':'
  # # local retcmds='trap - RETURN'
  # trap 'eval "$retcmds"' RETURN
  # retcmds="echo Returning from main \$var RETURN; $retcmds"
  echo Main
  foo
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  trap_return "$@"
fi
