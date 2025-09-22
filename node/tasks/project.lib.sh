# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3ded9cb-false}" && return 0; sourced_3ded9cb=true

. ./task.sh
. ./node.lib.sh
  add_sub_help_for_npm
. ./ip-utils.lib.sh

# Build
task_build() {
  rm -fr dist/
  run_node_modules_bin .bin/tsc
}

# Watch input and build accordingly
task_watchbuild() {
  run_node_modules_bin .bin/tsc --watch
}

# Run JavaScript script in the original working directory
subcmd_run() {
  node "$PROJECT_DIR"/dist/helper/launch-script.js "$PWD" "$@"
}

# Install the shims for scripts
subcmd_install() {
  local node_bin_dir_path="$HOME"/node-bin
  rm -fr "$node_bin_dir_path"
  mkdir -p "$node_bin_dir_path"
  rm -f ./*.js
  call_task task_build
  local js_file
  push_dir "$PROJECT_DIR"/dist/
  for js_file in *.js
  do
    test -r "$js_file" || continue
    case "$js_file" in
      (_*) continue;;
    esac
    local js_name="${js_file%.*}"
    if is_windows
    then
      local js_bin_file_path="$node_bin_dir_path"/"$js_name".cmd
      cat <<EOF > "$js_bin_file_path"
@echo off
"$PROJECT_DIR"\task.cmd run "$PROJECT_DIR\\dist\\${js_file}" %* || exit /b !ERRORLEVEL!
EOF
    else
      local js_bin_file_path="$node_bin_dir_path"/"$js_name"
      cat <<EOF > "$js_bin_file_path"
#!/bin/sh
exec "$PROJECT_DIR"/task run "$PROJECT_DIR/dist/${js_file}" "\$@"
EOF
      chmod +x "$js_bin_file_path"
    fi
  done
  pop_dir
}

# [<dir = $PWD>] Run a simple HTTP server.
subcmd_httpd() {
  push_dir "$PROJECT_DIR"
  local path="$INITIAL_PWD"
  if test "${1+set}" = set
  then
    path="$(cd "$INITIAL_PWD"; realpath "$1")"
  fi
  local host=127.0.0.1
  local port="$(ip_random_free_port)"
  INVOCATION_MODE=background node "$PROJECT_DIR"/dist/helper/httpd-mini.js "$path" "$host" "$port"
  pop_dir
  while true
  do
    menu \
      "&Browse" \
      "E&xit" \
      # nop
    case "$(get_key)" in
      (b) browse "http://$host:$port" ;;
      (x) break ;;
    esac
  done
}
