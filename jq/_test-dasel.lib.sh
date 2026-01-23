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

toml_5bd7f91() {
  cat <<EOF
foo = "FOO"
# comment
bar = "BAR"
baz = "BAZ"
EOF
}

yaml_expected_6d39916() {
  cat <<EOF
foo: FOO
# comment
bar: BAR HOGE
baz: BAZ
EOF
}

# Dasel does not support TOML comment
# test_dasel_comment() {
#   local toml="$(toml_5bd7f91 | dasel '.bar = .bar + " HOGE"')"
#   assert_eq "$(yaml_expected_6d39916)" "$toml"
# }

# Not kept
# $ printf "'foo' = 'FOO BAR'\n# hoge hoge\nbar = 'BAZ'" | t dasel3 --root -i toml -o toml 'foo = foo + ""'

# . ./task-sh/qq.lib.sh

# qq does not support TOML comment
# test_qq_comment() {
#   # local toml="$(toml_5bd7f91 | qq --input=toml '.bar = .bar + " HOGE"')"
#   local toml="$(toml_5bd7f91 | qq --input=toml '.')"
#   echo d: "$toml"
#   # assert_eq "$(yaml_expected_6d39916)" "$toml"
# }
