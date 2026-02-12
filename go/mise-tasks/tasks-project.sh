# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c572edd-false}" && return 0; sourced_c572edd=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

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

gen_win_shim_0d8d45c() { cat <<EOF
@echo off
pushd $pwd_backslash
call task.cmd "$task" "$name"
popd
$go_build_dir_path_backslash\\$name.exe %*
EOF
}

gen_unixy_shim_3b0072c() { cat <<EOF
#!/usr/bin/env sh
saved_pwd="\$PWD"
cd "$PWD"
./task "$task" "$name"
cd "\$saved_pwd"
exec $PWD/build/$name "\$@"
EOF
}

# Install Go tools.
task_install() {
  local task="./mise-tasks/tasks-project.sh:task_depbuild"
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
      gen_win_shim_0d8d45c >"$target_shim_path".cmd
    else
      gen_unixy_shim_3b0072c >"$target_shim_path"
      chmod +x "$target_shim_path"
    fi
  done
}

case "${0##*/}" in
  (tasks-*)
    set -o nounset -o errexit
    "$@"
    ;;
esac
