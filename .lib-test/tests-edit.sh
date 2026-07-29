# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c28ce41-false}" && return 0; sourced_c28ce41=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/edit.sh
. ../.lib/assert.sh
hello_sh_7dad95b="$PWD"/testdata/hello.sh
hello_txt_e48f9dc="$PWD"/testdata/hello.txt
cd "$3" || exit; shift 3

test_edit() {
  local function_text
  function_text="$(extract_block "^hello()" "^}" "$hello_sh_7dad95b")"
  assert_eq "$(cat <<EOF
hello() {
  echo Hello
}
EOF
)" "$function_text"

  local function_line_num
  function_line_num="$(echo "$function_text" | wc -l)"
  assert test 3 -eq "$function_line_num"

  local count_before
  count_before="$(wc -l <"$hello_sh_7dad95b")"
  local count_after
  count_after="$(exclude_block "^hello()" "^}" "$hello_sh_7dad95b" | wc -l)"
  assert test $((count_before - function_line_num)) -eq "$count_after"

  assert test 4 -eq "$(extract_before 881e6d7 "$hello_txt_e48f9dc" | wc -l)"
  assert test 5 -eq "$(extract_after 881e6d7 "$hello_txt_e48f9dc" | wc -l)"
}
