#!/usr/bin/env bash
set -- _61a6884 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

py_scr_db89bdf='import sys;original_wokrking_dir_path = sys.argv[1];import os;import subprocess;scr_path = os.path.abspath(sys.argv[2]);os.chdir(original_wokrking_dir_path);process = subprocess.Popen([sys.executable, scr_path] + sys.argv[3:]);process.wait();sys.exit(process.returncode);' #EMBED: ./_runner.py

# Run a script.
task_run() (
  cd "$PROJECT_DIR" || exit 1
  mise exec uv -- uv run python -c "$py_scr_db89bdf" "$INITIAL_DIR" "$@"
)
