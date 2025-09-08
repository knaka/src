# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0a5b825-false}" && return 0; sourced_0a5b825=true

. ./task.sh
. ./_assert.lib.sh

test_examples() (
  set -o errexit

  assert_eq "aaabbbccc" "$(echo '["a", "b", "c"]' | jq -r 'map(. * 3) | join("")')" "Apply map to the array and join the resulting array"
)
