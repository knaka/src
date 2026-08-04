#!/usr/bin/env bash
set -- _8e6944f "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

foo() {
  local retcmds="trap - RETURN"
  trap 'eval "$retcmds"' RETURN
  retcmds="echo Hello ; $retcmds"
}

foo
