#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_bd3b2a1-false}" && return 0; sourced_bd3b2a1=true

# This file demonstrates various approaches to count lines in shell variables.
#
# Note: Shell command substitution $(…) and `…` remove trailing newlines, making
# variables unsuitable for line counting. In production code, use temporary files
# instead, which preserve newlines and allow direct use of grep -c or wc -l.
#
# How to avoid bash command substitution to remove the newline character? - Stack Overflow https://stackoverflow.com/questions/15184358/how-to-avoid-bash-command-substitution-to-remove-the-newline-character

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
  register_temp_cleanup
shift 2
cd "$1" || exit 1; shift
cd "$1" || exit 1; shift 2

file="$TEMP_DIR"/6127086.txt

cat <<EOF >"$file"
baz
bar baz
foo bar baz
EOF

grep -c xxx "$file" # 0 (correct)
grep -c foo "$file" # 1 (correct)
grep -c bar "$file" # 2 (correct)
grep -c baz "$file" # 3 (correct)

echo Incorrect: counts empty string as 1 line >&2
s="$(grep xxx "$file")"; echo "$s" | wc -l # 1 (incorrect)
s="$(grep foo "$file")"; echo "$s" | wc -l # 1 (correct)
s="$(grep bar "$file")"; echo "$s" | wc -l # 2 (correct)
s="$(grep baz "$file")"; echo "$s" | wc -l # 3 (correct)

echo Incorrect: Use printf to avoid trailing newline issue and wc -l counts newlines, not lines
s="$(grep xxx "$file")"; printf "%s" "$s" | wc -l # 0 (correct)
s="$(grep foo "$file")"; printf "%s" "$s" | wc -l # 0 (incorrect)

echo  Solution 1: Count non-empty lines with grep -c >&2
s="$(grep xxx "$file")"; printf "%s\n" "$s" | grep -c . # 0 (correct)
s="$(grep foo "$file")"; printf "%s\n" "$s" | grep -c . # 1 (correct)
s="$(grep bar "$file")"; printf "%s\n" "$s" | grep -c . # 2 (correct)
s="$(grep baz "$file")"; printf "%s\n" "$s" | grep -c . # 3 (correct)

echo Solution 2: Use awk to count lines properly >&2
s="$(grep xxx "$file")"; printf "%s" "$s" | awk 'END {print NR}' # 0 (correct)
s="$(grep foo "$file")"; printf "%s" "$s" | awk 'END {print NR}' # 1 (correct)
s="$(grep bar "$file")"; printf "%s" "$s" | awk 'END {print NR}' # 2 (correct)
s="$(grep baz "$file")"; printf "%s" "$s" | awk 'END {print NR}' # 3 (correct)

echo Solution 3: Use a custom function to count lines >&2
count_lines_b8ba285() {
  test -z "$1" && echo 0 && return
  printf "%s\n" "$1" | wc -l
}
s="$(grep xxx "$file")"; count_lines_b8ba285 "$s" # 0 (correct)
s="$(grep foo "$file")"; count_lines_b8ba285 "$s" # 1 (correct)
s="$(grep bar "$file")"; count_lines_b8ba285 "$s" # 2 (correct)
s="$(grep baz "$file")"; count_lines_b8ba285 "$s" # 3 (correct)

echo Solution 4: Use return code to switch >&2
for i in xxx foo bar baz
do
  if s="$(grep "$i" "$file")"
  then
    count="$(echo "$s" | wc -l)"
  else
    count=0
  fi
  echo "$count"
done

echo Solution 5: Count using parameter expansion without subshell or external commands >&2
# Count newlines by iterating through the string
count_lines_param() {
  test -z "$1" && echo 0 && return
  set -- "$1" 0
  while :
  do
    case "$1" in
      (*"$newline_char"*)
        set -- "${1#*"$newline_char"}" $(($2 + 1))
        ;;
      (*)
        break
        ;;
    esac
  done
  echo $(($2 + 1))
}

s="$(grep xxx "$file")"; count_lines_param "$s" # 0 (correct)
s="$(grep foo "$file")"; count_lines_param "$s" # 1 (correct)
s="$(grep bar "$file")"; count_lines_param "$s" # 2 (correct)
s="$(grep baz "$file")"; count_lines_param "$s" # 3 (correct)

echo Solution 6: Use set -- to split by newlines and count positional parameters >&2

# Count lines in a string.
#
# Counts by splitting on newlines and using positional parameters. This approach
# avoids external commands and uses shell built-ins only.
count_lines_b8ba285() {
  local saved_ifs="$IFS"
  IFS="$newline_char"
  # shellcheck disable=SC2086
  set -- $1
  echo "$#"
  IFS="$saved_ifs"
}

count_lines_b8ba285 "hello" # 1 (incorrect)
s="$(grep xxx "$file")"; count_lines_b8ba285 "$s" # 0 (correct)
s="$(grep foo "$file")"; count_lines_b8ba285 "$s" # 1 (correct)
s="$(grep bar "$file")"; count_lines_b8ba285 "$s" # 2 (correct)
s="$(grep baz "$file")"; count_lines_b8ba285 "$s" # 3 (correct)

echo Solution 7: Use positional parameters. >&2

# Note: Command substitution behaves differently with set -e depending on context:
# - Pure assignment: x=$(failing_cmd) DOES trigger set -e
# - Declaration with assignment: local x=$(failing_cmd) does NOT (local's success masks it)
# - Command argument: set -- $(failing_cmd) does NOT (set's success masks it) bash-errexit-and-command-substitution-32edaeaae36d
#
# shellcheck disable=SC2046
x2702fbe() {
  local saved_ifs="$IFS"
  IFS="$newline_char"
  set -- $(grep xxx "$file"); echo "$#" # 0 (correct)
  # shellcheck disable=SC2046
  set -- $(grep foo "$file"); echo "$#" # 1 (correct)
  # shellcheck disable=SC2046
  set -- $(grep bar "$file"); echo "$#" # 2 (correct)
  # shellcheck disable=SC2046
  set -- $(grep baz "$file"); echo "$#" # 3 (correct)
  IFS="$saved_ifs"
}

set -o errexit
x2702fbe
