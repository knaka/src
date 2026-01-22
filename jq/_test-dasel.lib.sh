# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_08e719e-false}" && return 0; sourced_08e719e=true

. ./task.sh
. ./dasel.lib.sh
. ./_assert.lib.sh

# shellcheck disable=SC2016 # Expressions don't expand in single quotes, use double quotes for that.
# Test
test_dasel() {
  # dasel2 seems have omitted `--compact` option
  local json="$(echo '{"greeting": "Hello, world", "foo": "bar"}' | jq --compact-output --sort-keys)"
  local toml="$(echo "$json" | dasel --read=json --write=toml)"
  local greeting="$(echo "$toml" | dasel --read=toml --write=- '.greeting')"
  assert_eq "Hello, world" "$greeting"
  local json2="$(echo "$toml" | dasel --read=toml --write=json | jq -cS)"
  assert_eq "$json2" "$json"
}
