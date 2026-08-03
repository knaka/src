# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_cba2d9f-false}" && return 0; sourced_cba2d9f=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
. ../.lib/path.sh
. ../.lib/memoize.sh
cd "$3" || exit; shift 3

test_abs2rel() {
  local relpath
  if is_bbwin
  then
    relpath="$(abs2rel "$PWD/sh" "$PWD/go")"
    local current_drive_letter
    current_drive_letter="$(pwd | sed -Ee 's/^(.).*/\1/')"
    assert_eq "$relpath" "${current_drive_letter}:../sh"
    # relpath="$(abs2rel C:/Windows/System32)"
    # assert_match -m "bf12b50" '^[A-Z]:\.\.' "$relpath"
    # assert test -d "$relpath"
    # relpath="$(abs2rel C:/Windows/System32 C:/Windows)"
    # assert_eq "C:System32" "$relpath"
    # relpath="$(abs2rel C:/Windows C:/Windows/System32)"
    # assert_eq "C:.." "$relpath"
    # relpath="$(abs2rel /Windows /Windows/System32)"
    # assert_eq ".." "$relpath"
    # relpath="$(abs2rel /Windows/System32 /Windows/System)"
    # assert_eq "../System32" "$relpath"
    # relpath="$(abs2rel C:/Windows/System32 C:/Windows/System32)"
    # assert_eq -m "e057121" "C:." "$relpath"
    # relpath="$(abs2rel C:/ C:/Windows/System32)"
    # assert_eq -m "6724104" "C:../.." "$relpath"
    # relpath="$(abs2rel C:/Windows/System32 D:/Somewhere/Foo/Bar)"
    # assert_eq -m "349094b" "C:/Windows/System32" "$relpath"
  elif is_msys2
  then
    relpath="$(abs2rel "$PWD/sh" "$PWD/go")"
    assert_eq "$relpath" "../sh"
    relpath="$(abs2rel /c/Windows/System32)"
    assert_match -m "bf12b50" '^\.\.' "$relpath"
    assert test -d "$relpath"
    relpath="$(abs2rel /c/Windows/System32 /c/Windows)"
    assert_eq "System32" "$relpath"
    relpath="$(abs2rel /c/Windows /c/Windows/System32)"
    assert_eq ".." "$relpath"
    relpath="$(abs2rel /Windows /Windows/System32)"
    assert_eq ".." "$relpath"
    relpath="$(abs2rel /Windows/System32 /Windows/System)"
    assert_eq "../System32" "$relpath"
    relpath="$(abs2rel /c/Windows/System32 /c/Windows/System32)"
    assert_eq -m "e057121" "." "$relpath"
    relpath="$(abs2rel /c/ /c/Windows/System32)"
    assert_eq -m "6724104" "../.." "$relpath"
    relpath="$(abs2rel C:/Windows/System32 D:/Somewhere/Foo/Bar)"
    assert_eq -m "349094b" "C:/Windows/System32" "$relpath"
  else
    relpath="$(abs2rel "$PWD/sh" "$PWD/go")"
    assert_eq "$relpath" "../sh"
    relpath="$(abs2rel /usr/bin)"
    assert_match -m "bf12b50" '\.\.' "$relpath"
    assert test -d "$relpath"
    relpath="$(abs2rel /usr/bin /usr)"
    assert_eq "bin" "$relpath"
    relpath="$(abs2rel /usr /usr/bin)"
    assert_eq ".." "$relpath"
    relpath="$(abs2rel /usr /usr/lib)"
    assert_eq ".." "$relpath"
    relpath="$(abs2rel /usr/bin /usr/lib)"
    assert_eq "../bin" "$relpath"
    relpath="$(abs2rel /usr/bin /usr/bin)"
    assert_eq -m "e057121" "." "$relpath"
    relpath="$(abs2rel / /usr/bin)"
    assert_eq -m "6724104" "../.." "$relpath"
  fi
}

counter_268b0bb=

increment_2cfb6e4() {
  first_call aa08b06 || return 0
  first_call 74cfdba || :
  counter_268b0bb=$((counter_268b0bb + 1))
}

test_first_call() {
  counter_268b0bb=0
  increment_2cfb6e4
  assert_eq "$counter_268b0bb" 1
  init_temp_dir
  # Spaces in dir name.
  local dir="$TEMP_DIR/foo bar   baz"
  mkdir "$dir"
  cd "$dir" || exit 1
  increment_2cfb6e4
  assert_eq "$counter_268b0bb" 2
  cd ..
  increment_2cfb6e4
  assert_eq "$counter_268b0bb" 3
  cd "$dir" || exit 1
  increment_2cfb6e4
  assert_eq "$counter_268b0bb" 3
}

counter_81344cf=

increment_d1d63b0() {
  counter_81344cf=$((counter_81344cf + 1))
}

test_run_once() {
  counter_81344cf=0
  run_once increment_d1d63b0
  assert_eq "$counter_81344cf" 1
  init_temp_dir
  # Spaces in dir name.
  local dir="$TEMP_DIR/hoge fuga   foo"
  mkdir "$dir"
  cd "$dir" || exit 1
  run_once increment_d1d63b0
  assert_eq "$counter_81344cf" 2
  cd ..
  run_once increment_d1d63b0
  assert_eq "$counter_81344cf" 3
  cd "$dir" || exit 1
  run_once increment_d1d63b0
  assert_eq "$counter_81344cf" 3
  run_once increment_d1d63b0 hoge
  run_once increment_d1d63b0 fuga foo
  assert_eq "$counter_81344cf" 5
}

cleanup1sh() { echo cleanup1sh; };
cleanup2sh() { echo cleanup2sh; };
cleanup3sh() { echo cleanup3sh; };

test_register_exit_handler_sh() {
  local temp_file
  temp_file="$(mktemp)"
  add_exit_handler cleanup1sh
  (
    add_exit_handler cleanup2sh
    add_exit_handler cleanup3sh
  ) >"$temp_file"
  grep -q cleanup1sh "$temp_file" && false
  grep -q cleanup2sh "$temp_file" || false
  grep -q cleanup3sh "$temp_file" || false
  rm -f "$temp_file"
}

counter_path_df088c2=

init_counter_00c8d2f() {
  init_temp_dir
  counter_path_df088c2="$TEMP_DIR"/counter_34b7258
  echo 0 >"$counter_path_df088c2"
}

some_heavy_8403e65() {
  echo Hello, World! "$@"
  echo Doing something heavy...
  local counter
  counter="$(cat "$counter_path_df088c2")"
  echo Counter "$counter"
  echo Counter "$counter" >&2
  echo $((counter + 1)) >"$counter_path_df088c2"
}

some_heavy_wrapper_50305e1() {
  try_memoize f3155cf "$@" || return 0
  some_heavy_8403e65
  # And other heavy loads...
  end_memoize
}

test_block_memoize() {
  local result1
  local result2
  local counter

  init_counter_00c8d2f

  result1="$(some_heavy_8403e65)" # 1
  result2="$(some_heavy_8403e65)" # 2
  assert_neq "$result1" "$result2"

  counter="$(cat "$counter_path_df088c2")"
  assert_eq "$counter" 2

  result1="$(some_heavy_wrapper_50305e1)" # 3
  result2="$(some_heavy_wrapper_50305e1)" # 3
  assert_eq "$result1" "$result2"
  assert test -n "$result1"

  counter="$(cat "$counter_path_df088c2")"
  assert_eq "$counter" 3
}

some_failure_0f0189f() {
  echo Hello
  false
}

test_memoize() {
  local result1
  local result2
  local counter

  init_counter_00c8d2f

  result1="$(some_heavy_8403e65)" # 1
  result2="$(some_heavy_8403e65)" # 2
  assert_neq "$result1" "$result2"

  counter="$(cat "$counter_path_df088c2")"
  assert_eq "$counter" 2

  result1="$(memoize some_heavy_8403e65)" # 3
  result2="$(memoize some_heavy_8403e65)" # 3
  assert_eq -m 5211d9b "$result1" "$result2"
  assert test -n "$result1"

  counter="$(cat "$counter_path_df088c2")"
  assert_eq -m 80e4c5c "$counter" 3
}

test_memoize_failure() {
  local result
  if result="$(memoize some_failure_0f0189f)"
  then
    false
  else
    true
  fi
  test -n "$result"
  if result="$(memoize some_failure_0f0189f)"
  then
    false
  else
    true
  fi
}

test_assign_stdin() {
  init_temp_dir
  local expected_file="$TEMP_DIR"/7067d45
  local result_file="$TEMP_DIR"/dd9f0e5
  local foo=

  printf "Hello\nWorld!" >"$expected_file"
  assign_stdin foo <"$expected_file"
  printf "%s" "$foo" >"$result_file"
  is_windows && ls -l "$TEMP_DIR"
  assert test -s "$result_file"
  assert cmp "$expected_file" "$result_file"

  printf "Hello\nWorld!\n" >"$expected_file"
  assign_stdin foo <"$expected_file"
  printf "%s" "$foo" >"$result_file"
  assert test -s "$result_file"
  assert cmp "$expected_file" "$result_file"
}
