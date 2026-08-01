#!/usr/bin/env sh
set -- _fa7c29a "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

git diff --cached "$@"
