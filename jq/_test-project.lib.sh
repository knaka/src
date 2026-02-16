# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_65c09fd-false}" && return 0; sourced_65c09fd=true

. ./utils.lib.sh
. ./test.lib.sh
. ./_assert.lib.sh

yaml_021812a() {
  cat <<EOF
foo: FOO
# comment
bar: BAR
baz: BAZ
EOF
}

yaml_expected_015a1fa() {
  cat <<EOF
foo: FOO
# comment
bar: BAR HOGE
baz: BAZ
EOF
}

test_yq_comment() {
  local yaml="$(yaml_021812a | yq '.bar = .bar + " HOGE"')"
  assert_eq "$(yaml_expected_015a1fa)" "$yaml"
}

toml_9d4a9bb() {
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
  toml_9d4a9bb | yq --input-format=toml --output-format=yaml
  # Cannot output TOML.
  # toml_9d4a9bb | yq --input-format=toml --output-format=toml
}
