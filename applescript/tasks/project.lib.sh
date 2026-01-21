# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_beea234-false}" && return 0; sourced_beea234=true

. ./task.sh

task_build() {
  local source
  local dest
  for source in *.applescript
  do
    test -f "$source" || continue
    dest="${source%.applescript}.scpt"
    older "$source" --than "$dest" && continue
    osacompile -o "$dest" "$source"
  done
}
