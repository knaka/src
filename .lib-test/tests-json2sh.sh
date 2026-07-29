# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_23969e5-false}" && return 0; sourced_23969e5=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@"
. ../.lib/assert.sh
. ../.lib/json2sh.sh
cd "$3" || exit; shift 3

json2sh_expected() {
  cat <<EOF
json__user__name="Alice"
json__user__age="30"
json__items__0="apple"
json__items__1="banana"
EOF
}

test_json2sh() {
  init_temp_dir
  
  local expected="$TEMP_DIR/390f638.sh"
  json2sh_expected >"$expected"

  local actual="$TEMP_DIR/d06580e.sh"
  echo '{"user":{"name":"Alice","age":30},"items":["apple","banana"]}' | json2sh >"$actual"

# cat -n "$expected"
# cat "$expected" | od

# cat -n "$actual"
# cat "$actual" | od

  assert_eq -m "4a3762e" \
    "$(sha256sum "$expected" | field 1)" \
    "$(sha256sum "$actual" | field 1)"
}
