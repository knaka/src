# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c572edd-false}" && return 0; sourced_c572edd=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift

# Generate Go-inlined sample scripts.
task_hello_sh__gen() {
  gen_go_inlined \
    --main-file=./misc/hello.go \
    --output=./misc/hello.sh
}

# Generate files.
task_gen() {
  call_task task_hello_sh__gen
}

# Build Go source packages (*.go, ./cmd/*/) incrementally.
task_depbuild() {
  push_dir "$PROJECT_DIR"
  local go_bin_dir_path=./build
  mkdir -p "$go_bin_dir_path"
  if test $# = 0
  then
    # shellcheck disable=SC2038
    # shellcheck disable=SC2046
    set -- *.go $(find cmd -mindepth 1 -maxdepth 1 | xargs basename)
  fi
  local arg
  for arg in "$@"
  do
    # Remove ".go" suffix
    arg="${arg%.go}"
    if test -r "$arg.go"
    then
      local target_cmd_path="$go_bin_dir_path/$arg$exe_ext"
      if ! test -x "$target_cmd_path" || newer "$arg.go" --than "$target_cmd_path"
      then
        "$VERBOSE" && echo "Building $arg.go" >&2
        go build -o "$target_cmd_path" "$arg.go"
      fi
    elif test -d ./cmd/"$arg"
    then
      local target_cmd_path="$go_bin_dir_path/$arg$exe_ext"
      if ! test -x "$target_cmd_path" || newer ./cmd/"$arg" --than "$target_cmd_path"
      then
        "$VERBOSE" && echo "Building ./cmd/$arg" >&2
        go build -o "$target_cmd_path" ./cmd/"$arg"
      fi
    else
      :
    fi
  done
  pop_dir
}

# DEPREATED
task_build() {
  task_depbuild "$@"
}

# Install Go tools.
task_install() {
  local task="./mise-tasks/project.lib.sh:task_depbuild"
  local go_shim_dir_path="$HOME"/go-bin
  mkdir -p "$go_shim_dir_path"
  rm -f "$go_shim_dir_path"/*
  local go_main_path
  local name
  local target_shim_path
  for go_main_path in *.go cmd/*
  do
    if ! test -r "$go_main_path" && ! test -d "$go_main_path"
    then
      continue
    fi
    case "$go_main_path" in
      task.go|task-*.go) continue ;;
    esac
    name=$(basename "$go_main_path" .go)
    target_shim_path="$go_shim_dir_path/$name"
    if is_windows
    then
      local pwd_backslash="$(echo "$PWD" | sed 's|/|\\|g')"
      go_build_dir_path_backslash=$(echo "$(realpath .)"/build | sed 's|/|\\|g')
      cat <<EOF >"$target_shim_path".cmd
@echo off
pushd $pwd_backslash
call task.cmd "$task" "$name"
popd
$go_build_dir_path_backslash\\$name.exe %*
EOF
    else
      cat <<EOF >"$target_shim_path"
#!/bin/sh
saved_pwd="\$PWD"
cd "$PWD"
./task "$task" "$name"
cd "\$saved_pwd"
exec $PWD/build/$name "\$@"
EOF
      chmod +x "$target_shim_path"
    fi
  done
}
