#!/bin/sh
test "${guard_932ee57+set}" = set && return 0; guard_932ee57=-

. ./task.sh

# Tags · knaka/gorun https://github.com/knaka/gorun/tags
: "${gorun_version:=v0.1.1}"

set_gorun_version() {
  gorun_version="$1"
}

subcmd_gorun() { # Executes Go main package `pkg_name@ver` with arguments and cache the binary to reuse.
  local app_dir_path
  app_dir_path="$(get_cache_dir_path)"/app-gorun
  mkdir -p "$app_dir_path"
  local cmd_ext=
  if is_windows
  then
    cmd_ext=.cmd
  fi
  local cmd_base=gorun@"$gorun_version""$cmd_ext"
  local cmd_path="$app_dir_path"/"$cmd_base"
  if ! test -x "$cmd_path"
  then
    cross_run curl --fail --location --output "$cmd_path" https://raw.githubusercontent.com/knaka/gorun/refs/tags/"$gorun_version"/gorun"$cmd_ext"
    chmod +x "$cmd_path"
  fi
  "$cmd_path" "$@"
}
