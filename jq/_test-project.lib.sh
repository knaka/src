# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0a5b825-false}" && return 0; sourced_0a5b825=true

. ./task.sh
. ./_assert.lib.sh

test_examples() (
  set -o errexit

  assert_eq "aaabbbccc" "$(echo '["a", "b", "c"]' | jq -r 'map(. * 3) | join("")')" "Apply map to the array and join the resulting array"

  json="$TEMP_DIR"/8f57625.json
  echo '
    [
      { "name": "Alice, ALICE", "email": "alice@example.com" },
      { "name": "Alice, ALICE", "email": "another_alice@example.com" },
      { "name": "Bob, BOB", "email": "bob@example.com" }
    ]
  ' >"$json"

  printf "%s$us%s$us%s\n" \
    'Alice, ALICE' true '{"name":"Alice, ALICE","email":"alice@example.com"}' \
    'Bob, BOB' true '{"name":"Bob, BOB","email":"bob@example.com"}' \
    'Charlie, CHARLIE' false '' \
    'David, DAVID' false '' \
  | (
    IFS="$us"
    count=0
    while read -r name must_succeed expected
    do
      if result="$(jq -c -e --arg name "$name" '[.[] | select(.name == $name)][0]' <"$json")"
      then
        if "$must_succeed"
        then
          assert_eq "$expected" "$result"
        else
          echo "Must fail (87fea64)" >&2
          false
        fi
      else
        if "$must_succeed"
        then
          echo "Must succeed (43c9be7)" >&2
          false
        fi
      fi
      count=$((count + 1))
    done
    assert_true test "$count" -eq 4
  )
)

json2sh_expected() {
  cat <<EOF
json__user_name="Alice"
json__user_age="30"
json__items_0="apple"
json__items_1="banana"
EOF
}

test_json2sh() {
  local expected="$TEMP_DIR/0fff639.sh"
  json2sh_expected >"$expected"

  local actual="$TEMP_DIR/ffe3871.sh"
  echo '{"user":{"name":"Alice","age":30},"items":["apple","banana"]}' | jq -r -f json2sh.jq >"$actual"

  assert_eq \
    "$(sha256sum "$expected" | field 1)" \
    "$(sha256sum "$actual" | field 1)"
}
