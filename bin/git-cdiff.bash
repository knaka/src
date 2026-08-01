#!/usr/bin/env sh
set -- _BIN_GIT_CDIFF_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

git diff --cached "$@"
