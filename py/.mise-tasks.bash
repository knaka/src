#!/usr/bin/env bash
set -- _PY__MISE_TASKS_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/commands.sh
. ../.lib/embed-script.sh
popd >/dev/null || exit

# TODO: Fix runner path.
gen_cmd_script_5712688() { cat <<EOF
@ECHO OFF
set INITIAL_DIR=%CD%
cd ${PROJECT_DIR}
call task.cmd ./mise-tasks/tasks-project.sh:task_run ${1} %*
EOF
}

gen_sh_script_a581384() { cat <<EOF
#!/usr/bin/env sh
cd "$PROJECT_DIR"
exec mise exec -- uv run python3 _chdir.py "\$OLDPWD" "$PROJECT_DIR"/"$file" "\$@"
EOF
}

# mise exec -- uv tool run python3

# Install scripts.
task_install() {
  push_dir "$PROJECT_DIR"
  local bin_dir_path="$HOME"/py-bin
  mkdir -p "$bin_dir_path"
  rm -f "${bin_dir_path:?}"/*
  local file
  for file in *.py
  do
    test -r "$file" || continue
    case "$file" in
      (_*) continue;;
    esac
    local name="${file%.py}"
    gen_sh_script_a581384 "$file" >"$bin_dir_path"/"$name"
    chmod +x "$bin_dir_path"/"$name"
  done
  pop_dir
}

# Updates the UV virtualenv.
task_sync() {
  cd "$PROJECT_DIR" || exit
  uv sync "$@"
}

# Embed scripts.
task_embed() {
  embed_minified \
    ./.mise-tasks-run.bash \
    #nop
}

# Foo
task_foo() {
  cd "$PROJECT_DIR" || exit
  no_indent_script="$(cat <<'EOF'
print('Hello, World!')
print('This is a Python script.')
[print(i) for i in range(10)]
EOF
)"
  no_indent_script="$(echo "$no_indent_script" | tr '\n' ';')"
  uv run python -c "$no_indent_script"
}
