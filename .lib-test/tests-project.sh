# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_cba2d9f-false}" && return 0; sourced_cba2d9f=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.sh
. ./.lib/assert.sh
. ./.lib/path.sh
. ./.lib/memoize.sh
shift 2
cd "$1" || exit 1; shift

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
  counter_268b0bb=$((counter_268b0bb + 1))
}

test_first_call() {
  counter_268b0bb=0
  increment_2cfb6e4
  increment_2cfb6e4
  increment_2cfb6e4
  increment_2cfb6e4
  increment_2cfb6e4
  increment_2cfb6e4
  assert_eq "$counter_268b0bb" 1
}

cleanup1sh() { echo cleanup1sh; };
cleanup2sh() { echo cleanup2sh; };
cleanup3sh() { echo cleanup3sh; };

test_prepend_cleanup_sh() {
  local temp_file
  temp_file="$(mktemp)"
  prepend_cleanup cleanup1sh
  (
    prepend_cleanup cleanup2sh
    prepend_cleanup cleanup3sh
  ) >"$temp_file"
  grep -q cleanup1sh "$temp_file" && false
  grep -q cleanup2sh "$temp_file" || false
  grep -q cleanup3sh "$temp_file" || false
  rm -f "$temp_file"
}

counter_path_df088c2=

init_counter_00c8d2f() {
  register_temp_cleanup
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
