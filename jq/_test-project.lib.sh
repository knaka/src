# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_65c09fd-false}" && return 0; sourced_65c09fd=true

. ./task.sh
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
