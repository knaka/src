#!/usr/bin/env bash
set -- _154547e "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# OK
[[ "$FOO" = *"$BAR"* ]]

# OK
[[ "$FOO" == *"$BAR"* ]]

# “Syntax error”
# [[ "$FOO" = *" $BAR $BAZ "* ]]

# “Syntax error”
# [[ "$FOO" = *"$BAR $BAZ"* ]]
