# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_beea234-false}" && return 0; sourced_beea234=true

. ./task.sh

# Compiles all .applescript files to .scpt (compiled binary) format. This function iterates through all .applescript source files in the current directory and compiles them using osacompile(1).
task_build() {
  local source
  local dest
  for source in *.applescript
  do
    test -f "$source" || continue
    dest="${source%.applescript}.scpt"
    newer "$source" --than "$dest" || continue
    osacompile -o "$dest" "$source"
    echo "Compiled $source ." >&2
  done
}
