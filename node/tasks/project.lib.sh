# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3ded9cb-false}" && return 0; sourced_3ded9cb=true

. ./task.sh
. ./node.lib.sh
  add_sub_help_for_npm

task_build() {
  npm run build
}

task_watchbuild() {
  npm run build:watch
}

# Run JS script in the original working directory.
subcmd_run() {
  node "$PROJECT_DIR"/scripts/launch-script.cjs "$PWD" "$@"
}

subcmd_install() {
  local node_bin_dir_path="$HOME"/node-bin
  rm -fr "$node_bin_dir_path"
  mkdir -p "$node_bin_dir_path"
  rm -f ./*.js
  task_build
  local js_file 
  for js_file in *.js *.mjs *.cjs
  do
    test -r "$js_file" || continue
    local js_name="${js_file%.*}"
    if is_windows
    then
      local js_bin_file_path="$node_bin_dir_path"/"$js_name".cmd
      cat <<EOF > "$js_bin_file_path"
@echo off
"$PWD"\task.cmd run "$PWD\\${js_file}" %* || exit /b !ERRORLEVEL!
EOF
    else
      local js_bin_file_path="$node_bin_dir_path"/"$js_name"
      cat <<EOF > "$js_bin_file_path"
#!/bin/sh
exec "$PWD"/task run "$PWD/${js_file}" "\$@"
EOF
      chmod +x "$js_bin_file_path"
    fi
  done
}
