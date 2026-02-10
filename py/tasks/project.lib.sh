# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_517f312-false}" && return 0; sourced_517f312=true

. ./task.sh
. ./python.lib.sh

# Install scripts.
task_install() (
  py_bin_dir_path="$HOME"/py-bin
  mkdir -p "$py_bin_dir_path"
  rm -f "$py_bin_dir_path"/*
  for py_file in *.py
  do
    if ! test -r "$py_file"
    then
      continue
    fi
    if echo ":invalid.py:" | grep -q ":$py_file:"
    then
      continue
    fi
    py_name="${py_file%.py}"
    if is_windows
    then
      py_bin_file_path="$py_bin_dir_path"/"$py_name.cmd"
      cat <<EOF > "$py_bin_file_path"
@echo off
"$PWD"/task.cmd run "$py_file" %*
EOF
    else
      py_bin_file_path="$py_bin_dir_path"/"$py_name"
      cat <<EOF > "$py_bin_file_path"
#!/bin/sh
exec "$PWD/task" run "$py_file" "\$@"
EOF
      chmod +x "$py_bin_file_path"
    fi
  done
)

# Run a script.
subcmd_run() (
  cd "$PROJECT_DIR"
  no_indent_script="$(cat <<'EOF'
import sys
original_wokrking_dir_path = sys.argv[1]
import os
import subprocess
scr_path = os.path.abspath(sys.argv[2])
os.chdir(original_wokrking_dir_path)
process = subprocess.Popen([sys.executable, scr_path] + sys.argv[3:])
process.wait()
sys.exit(process.returncode)
EOF
)"
  no_indent_script="$(echo "$no_indent_script" | tr '\n' ';')"
  uv run python -c "$no_indent_script" "$INITIAL_PWD" "$@"
)

# Updates the UV virtualenv.
subcmd_sync() {
  cd "$PROJECT_DIR"
  uv sync "$@"
}

subcmd_foo() {
  cd "$PROJECT_DIR"
  no_indent_script="$(cat <<'EOF'
print('Hello, World!')
print('This is a Python script.')
[print(i) for i in range(10)]
EOF
)"
  no_indent_script="$(echo "$no_indent_script" | tr '\n' ';')"
  uv run python -c "$no_indent_script"
}
