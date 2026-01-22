# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_40c4378-false}" && return 0; sourced_40c4378=true

. ./task.sh
. ./yj.lib.sh

toml_979e0bb() {
  cat <<EOF
foo = "bar"
"greeting message" = "Hello, world"
EOF
}

# shellcheck disable=SC2016 # Expressions don't expand in single quotes, use double quotes for that.
# Test
test_yj() {
  local json="$(toml_979e0bb | yj -tj | jq -cS)"
  assert_eq "bar" "$(echo "$json" | jq -r '.foo')"
  assert_eq "Hello, world" "$(echo "$json" | jq -r '."greeting message"')"
  local toml="$(echo "$json" | yj -jt)"
  assert_eq "$toml" "$(toml_979e0bb)"
}

toml_656e614() {
  jq -n '."foo bar" = {"hello": "Hello"} | ."bar baz" = 123.45' | yj -jt
}

test_toml_compo() {
  local json="$(toml_656e614 | yj -tj | jq -cS)"
  assert_eq '{"bar baz":123.45,"foo bar":{"hello":"Hello"}}' "$json"
}
