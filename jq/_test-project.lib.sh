# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_65c09fd-false}" && return 0; sourced_65c09fd=true

. ./task.sh
. ./test.lib.sh
. ./_assert.lib.sh

yaml_5bd7f91() {
  cat <<EOF
foo: FOO
# comment
bar: BAR
baz: BAZ
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

test_yq_comment() {
  local yaml="$(yaml_5bd7f91 | yq '.bar = .bar + " HOGE"')"
  assert_eq "$(yaml_expected_6d39916)" "$yaml"
}

toml_5bd7f91() {
  cat <<EOF
foo = "FOO"
# comment
bar = "BAR"
baz = "BAZ"
EOF
}

test_yq_toml() {
  skip_if true
  # Comment lines disappear.
  toml_5bd7f91 | yq --input-format=toml --output-format=yaml
  # Cannot output TOML.
  # toml_5bd7f91 | yq --input-format=toml --output-format=toml
}
