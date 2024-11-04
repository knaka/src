#!/bin/sh
set -o nounset -o errexit

test "${guard_429c89f+set}" = set && return 0; guard_429c89f=x

. ./task.sh
. ./assert.lib.sh

# First, check that errexit is on.
assert_match "^errexit[[:space:]]+on$" "$(set -o | grep -E '^errexit\b')"

# Fails to restore the state if it was not saved.
assert_false restore_state

# Save the state.
backup_state
assert_match '^set -o errexit$' "$original_state_c225b8f"

# Fails to save the state if it was already saved. Does not nest.
assert_false backup_state

# Turn it off.
set +o errexit
assert_match "^errexit[[:space:]]+off$" "$(set -o | grep -E '^errexit\b')"

# Restore the state.
restore_state