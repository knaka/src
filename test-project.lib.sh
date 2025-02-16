#!/bin/sh
# shellcheck disable=SC3043
# vim: tabstop=2 shiftwidth=2 noexpandtab
# -*- mode: sh; tab-width: 2; indent-tabs-mode: t -*-
test "${guard_8842fe8+set}" = set && return 0; guard_8842fe8=x
set -o nounset -o errexit

# shellcheck source=./tasks/assert.lib.sh
. ./assert.lib.sh
# shellcheck source=./tasks/task.sh
. ./task.sh

toupper_4c7e44e() {
  printf "%s" "$1" | tr '[:lower:]' '[:upper:]'
}

tolower_542075d() {
  printf "%s" "$1" | tr '[:upper:]' '[:lower:]'
}

test_version_comparison() (
  set -o errexit

  assert_true version_gt 1.0 0.9
  assert_true version_gt 1.1 1.0
  assert_true version_gt 1.1 1.0.9
  assert_true version_gt 1.1.1 1.1
  assert_true version_gt 1.1.1 1.1.0
  assert_true version_gt 1.1.1 1.1.1-alpha1
  assert_true version_gt v1.5.0-patch v1.5.0
  assert_true version_gt go1.23.2 go1.20.0
  assert_false version_gt 1.0 1.0
  assert_true version_ge 1.0 1.0

  assert_eq "v1,v1.4.3,v1.5.0," "$(IFS=, ifsv_sort "v1.5.0,v1,v1.4.3," sort_version)"
  assert_eq "v1.5.0,v1.4.3,v1," "$(IFS=, ifsv_sort "v1.5.0,v1,v1.4.3," sort_version -r)"

  cat <<EOF > "$(temp_dir_path)/versions.txt"
v1.4.0-alpha
v1.4.0-alpha1
v1.4.0-beta
v1.4.0-patch
v1.4.0-patch2
v1.4.0-patch9
v1.4.0-patch10
v1.4.0-rc1
v1.4.0
v1.5
v1.4
v1
v1.5.0-alpha
v1.5.0-alpha2
v1.5.0-alpha1
v1.5.0-beta
v1.5.0-patch
v1.5.0-patch1
v1.5.0-beta2
v1.5.0
EOF
  cat <<EOF > "$(temp_dir_path)/expected.txt"
v1
v1.4
v1.4.0-alpha
v1.4.0-alpha1
v1.4.0-beta
v1.4.0-rc1
v1.4.0
v1.4.0-patch
v1.4.0-patch2
v1.4.0-patch9
v1.4.0-patch10
v1.5
v1.5.0-alpha
v1.5.0-alpha1
v1.5.0-alpha2
v1.5.0-beta
v1.5.0-beta2
v1.5.0
v1.5.0-patch
v1.5.0-patch1
EOF
  sort_version <"$(temp_dir_path)/versions.txt" >"$(temp_dir_path)/actual.txt"
  assert_eq "$(cat "$(temp_dir_path)/expected.txt")" "$(cat "$(temp_dir_path)/actual.txt")"
)

test_menu_item() (
  set -o errexit

  assert_match ".+S.+ave" "$(menu_item "&Save")"
  assert_match "E.+x.+it" "$(menu_item "E&xit")"
  assert_match "Save & E.+x.+it" "$(menu_item "Save && E&xit")"
  assert_match "   Hello .+I.+ am" "$(menu_item "   Hello &I am")"
  assert_eq "" "$(menu_item "")"
  assert_eq "Exit" "$(menu_item "Exit")"
  # shellcheck disable=SC2016
  assert_match '.+A.+dd \$100' "$(menu_item '&Add $100')"
)

test_field() (
  set -o errexit

  assert_eq "foo" "$(echo "foo bar baz" | field 1)"
  assert_eq "bar" "$(echo "   foo      bar   baz  " | field 2)"
  assert_eq "baz" "$(printf "foo bar\nbaz qux\n" | field 3)"
)

# Split the text.
test_split() (
  set -o errexit

  assert_eq "foo,bar,baz" "$(echo "foo, bar,  baz" | sed -E -e "s/, *"/,/g)"
  assert_eq "foo${us}bar${us}baz" "$(echo "foo, bar,  baz" | sed -E -e "s/, */${us}/g")"
)

# Parse with sed(1) and process the text.
test_sed_usv() (
  set -o errexit

  input_path="$(temp_dir_path)/input.txt"
  cat <<'EOF' >"$input_path"
foo bar baz
other lines
123 456 789

hello world
hoge fuga hare
012 345 678 900
EOF
  output_path="$(temp_dir_path)/output.txt"
  sed -E \
    -e "s/^([[:alpha:]]{3}) ([[:alpha:]]{3}) ([[:alpha:]]{3})$/case1${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^([[:alpha:]]{4}) ([[:alpha:]]{4}) ([[:alpha:]]{4})$/case2${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^([[:digit:]]{3}) ([[:digit:]]{3}) ([[:digit:]]{3})$/case3${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^(.*)$/nop${us}\1${us}/" <"$input_path" \
  | while IFS= read -r line
  do
    IFS="$us"
    # shellcheck disable=SC2086
    set -- $line
    unset IFS
    op="$1"
    shift
    case "$op" in
      (case1)
        echo "a: $1 $2 $3"
        ;;
      (case2)
        echo "b: $1 $2 $3"
        ;;
      (case3)
        echo "c: $1 $2 $3"
        ;;
      (nop)
        echo "z: $1"
        ;;
      (*)
        echo "Unhandled operation: $op" >&2
        ;;
    esac  
  done >"$output_path"
  
  expected_path="$(temp_dir_path)/expected.txt"
  cat <<'EOF' >"$expected_path"
a: foo bar baz
z: other lines
c: 123 456 789
z: 
z: hello world
b: hoge fuga hare
z: 012 345 678 900
EOF

  assert_eq "$(shasum "$expected_path" | field 1)" "$(shasum "$output_path" | field 1)"
)

# Parse with sed(1) and execute the commands.
test_sed_usv_global() (
  set -o errexit

  input_path="$(temp_dir_path)/input.txt"
  cat <<'EOF' >"$input_path"
foo toupper(bar) baz toupper(qux) HOGE tolower(FUGA)
other lines
EOF
  output_path="$(temp_dir_path)/output.txt"
  sed -E \
    -e "s/${lwb}toupper${rwb}\(([[:alpha:]]+)\)/${is1}toupper_4c7e44e${is2}\1${is1}/g" \
    -e "s/${lwb}tolower${rwb}\(([[:alpha:]]+)\)/${is1}tolower_542075d${is2}\1${is1}/g" \
    -e "s/^(.*${is1}[[:alnum:]_]+${is2}.*)$/call${is1}\1${is1}/" -e t \
    -e "s/^(.*)$/nop${is1}\1${is1}/" <"$input_path" \
  | while IFS= read -r line
  do
    IFS="$is1"
    # shellcheck disable=SC2086
    set -- $line
    unset IFS
    op="$1"
    shift
    case "$op" in
      (call)
        for arg in "$@"
        do 
          case "$arg" in
            (*${is2}*)
              echo "$arg" | (
                IFS="$is2" read -r cmd param
                "$cmd" "$param"
              )
              ;;
            (*)
              printf "%s" "$arg"
              ;;
          esac
        done
        echo
        ;;
      (nop)
        echo "$1"
        ;;
      (*)
        echo "Unhandled operation: $op" >&2
        ;;
    esac
  done >"$output_path"
  # cat "$output_path" >&2
  expected_path="$(temp_dir_path)/expected.txt"
  cat <<'EOF' >"$expected_path"
foo BAR baz QUX HOGE fuga
other lines
EOF
  assert_eq "$(shasum "$expected_path" | field 1)" "$(shasum "$output_path" | field 1)"
)

# Test IFS push/pop functions.
test_ifs() (
  set -o errexit

  unset IFS

  push_ifs
  IFS=,
  assert_eq "," "$IFS"

  push_ifs
  IFS=:
  assert_eq ":" "$IFS"

  pop_ifs
  assert_eq "," "$IFS"

  pop_ifs
  assert_true test "${IFS+set}" != set
)

test_extra() (
  skip_unless_all

  echo "Executed extra test." >&2
)

test_not_existing_task() (
  assert_false invoke ./task not_existing_task
  invoke ./task --ignore-missing not_existing_task 2>&1 | grep "Unknown task"
  invoke ./task --skip-missing not_existing_task
)

test_dumper() (
  # Busybox Awk does not support --version option.
  # awk --version 2>&1
  result="$(echo hello | hex_dump | hex_restore)"
  assert_eq "hello" "$result"
  result="$(echo hello2 | oct_dump | oct_restore)"
  assert_eq "hello2" "$result"
)

is_ci() {
  test "${CI+set}" = set
}

is_ci_mac() {
  is_ci && is_macos
}

test_killing() {
  invoke ./task killng_test
}

test_shell() {
  if is_macos
  then
    assert_eq "dash" "$(shell_path)"
  elif is_windows
  then
    assert_eq "ash" "$(shell_path)"
  elif is_linux
  then
    assert_true test "dash" = "$(shell_path)" -o "ash" = "$(shell_path)" -o "bash" = "$(shell_path)"
  else
    echo "Unsupported platform." >&2
    return 1
  fi
}

test_newer() {
  local older current future

  older="$(temp_dir_path)"/older.txt
  current="$(temp_dir_path)"/current.txt
  future="$(temp_dir_path)"/future.txt

  touch -t 202101010000 "$older"  
  touch -t 202101020000 "$current"
  touch -t 202101030000 "$future" 

  assert_true newer "$current" "$future" --than "$older"
  assert_false newer "$current" "$older" --than "$future"
}

test_dir_stack() {
  cd "$PROJECT_DIR"
  
  push_dir ./tasks
  assert_eq "$PROJECT_DIR/tasks" "$PWD"
  assert_eq "$dirs_4c15d80" "$PROJECT_DIR|"
  pop_dir
  assert_eq "$PROJECT_DIR" "$PWD"
  assert_eq "$dirs_4c15d80" ""

  push_dir ./go
  assert_eq "$dirs_4c15d80" "$PROJECT_DIR|"
  push_dir ../sh
  assert_eq "$dirs_4c15d80" "$PROJECT_DIR/go|$PROJECT_DIR|"
  assert_eq "$PROJECT_DIR/sh" "$PWD"
  pop_dir
  pop_dir
}

args_restore_test() {
  local before1 before2 before3
  before1="$1"
  before2="$2"
  before3="$3"

  local eval_args
  eval_args="$(make_eval_args "$@")"

  set --
  assert_true test $# -eq 0

  eval "set -- $eval_args"

  assert_true test $# -eq 3

  assert_eq "$before1" "$1"
  assert_eq "$before2" "$2"
  assert_eq "$before3" "$3"
}

test_args_restore() {
  args_restore_test "hoge ' fuga" 'foo " bar' "$(printf "bar\nbaz")"
}

test_is_dir_empty() {
  local dir_path="$(temp_dir_path)"/17f146e

  assert_false is_dir_empty "$dir_path"

  mkdir -p "$dir_path"
  assert_true is_dir_empty "$dir_path"

  touch "$dir_path"/file
  assert_false is_dir_empty "$dir_path"  
}

test_fetch() {
  local url="https://www.example.com/"
  local output_path="$(temp_dir_path)"/output.html
  subcmd_fetch "$url" >"$output_path"
  grep -q "Example Domain" "$output_path"
}

test_fifo() {
  if is_windows
  then
    :
  elif is_linux || is_macos
  then
    local fifo_path="$(temp_dir_path)"/fifo
    mkfifo "$fifo_path"
    (
      for i in 1 2 3
      do
        sleep 0.1
        printf "hello%d" "$i"
      done
    ) >"$fifo_path" 2>&1 &
    local output_path="$(temp_dir_path)"/output
    cat "$fifo_path" >"$output_path"
    assert_eq "$(cat "$output_path")" "hello1hello2hello3"
  else
    echo "Unexpected platform." >&2
    return 1
  fi
}
