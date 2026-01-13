# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0a5b825-false}" && return 0; sourced_0a5b825=true

. ./task.sh
. ./_assert.lib.sh

test_examples() {
  assert_eq "aaabbbccc" "$(echo '["a", "b", "c"]' | jq -r 'map(. * 3) | join("")')" "Apply map to the array and join the resulting array"

  local input_json="$TEMP_DIR"/8f57625.json
  echo '
    [
      { "name": "Alice, ALICE", "email": "alice@example.com" },
      { "name": "Alice, ALICE", "email": "another_alice@example.com" },
      { "name": "Bob, BOB", "email": "bob@example.com" }
    ]
  ' | jq -c >"$input_json"

  printf "%s$us%s$us%s$us%s\n" \
    'Alice, ALICE' true '{"name":"Alice, ALICE","email":"alice@example.com"}' 'Returns the first matching entry' \
    'Bob, BOB' true '{"name":"Bob, BOB","email":"bob@example.com"}' 'Returns the matching entry' \
    'Charlie, CHARLIE' false '' 'Does not exist' \
    'David, DAVID' false '' 'Does not exist' \
  | (
    count=0
    while IFS="$us" read -r name must_succeed expected message
    do
      if result="$(jq -c -e --arg name "$name" '[.[] | select(.name == $name)][0]' <"$input_json")"
      then
        if "$must_succeed"
        then
          assert_eq "$expected" "$result" "$message"
        else
          echo "Must fail (87fea64): $message" >&2
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
    assert_eq "$count" 4
  )
}

json2sh_expected() {
  cat <<EOF
json__user__name="Alice"
json__user__age="30"
json__items__0="apple"
json__items__1="banana"
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
