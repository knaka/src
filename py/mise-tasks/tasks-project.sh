# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_517f312-false}" && return 0; sourced_517f312=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

gen_cmd_script_5712688() { cat <<EOF
@ECHO OFF
set INITIAL_DIR=%CD%
cd ${PROJECT_DIR}
call task.cmd ./mise-tasks/tasks-project.sh:task_run ${1} %*
EOF
}

gen_sh_script_a581384() { cat <<EOF
#!/usr/bin/env sh
export INITIAL_DIR="\$PWD"
cd "$PROJECT_DIR"
./task ./mise-tasks/tasks-project.sh:task_run "$1" "\$@"
EOF
}

# Install scripts.
task_install() {
  push_dir "$PROJECT_DIR"
  local bin_dir_path="$HOME"/py-bin
  mkdir -p "$bin_dir_path"
  rm -f "${bin_dir_path:?}"/*
  local file
  for file in *.py
  do
    test -e "$file" || continue
    case "$file" in
      (_*) continue;;
    esac
    local name="${file%.py}"
    if is_windows
    then
      gen_cmd_script_5712688 "$file" >"$bin_dir_path"/"$name".cmd
    else
      gen_sh_script_a581384 "$file" >"$bin_dir_path"/"$name"
      chmod +x "$bin_dir_path"/"$name"
    fi
  done
  pop_dir
}

py_scr_db89bdf='import sys;original_wokrking_dir_path = sys.argv[1];import os;import subprocess;scr_path = os.path.abspath(sys.argv[2]);os.chdir(original_wokrking_dir_path);process = subprocess.Popen([sys.executable, scr_path] + sys.argv[3:]);process.wait();sys.exit(process.returncode);' #EMBED: ./runner.py

# Run a script.
task_run() (
  cd "$PROJECT_DIR" || exit 1
  mise exec uv -- uv run python -c "$py_scr_db89bdf" "$INITIAL_DIR" "$@"
)

# Updates the UV virtualenv.
subcmd_sync() {
  cd "$PROJECT_DIR" || exit
  uv sync "$@"
}

# Foo
subcmd_foo() {
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
