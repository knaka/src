# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c572edd-false}" && return 0; sourced_c572edd=true

. ./task.sh
. ./go.lib.sh
. ./go-inlined.lib.sh

# Generate Go-inlined sample scripts.
task_hello_sh__gen() {
  gen_go_inlined \
    --main-file=./misc/hello.go \
    --output=./misc/hello.sh
}

# Generate files.
task_gen() {
  task_go_hello__gen
}

# Build Go source files incrementally.
subcmd_build() {
  cd "$PROJECT_DIR"
  local go_bin_dir_path=./build
  mkdir -p "$go_bin_dir_path"
  if test "${1+set}" != "set"
  then
    set -- *.go
  fi
  local arg
  for arg in "$@"
  do
    # Remove ".go" suffix
    arg="${arg%.go}"
    if test -r "$arg.go"
    then
      local target_bin_path="$go_bin_dir_path"/"$arg""$exe_ext"
      if ! test -x "$target_bin_path" || newer "$arg.go" --than "$target_bin_path"
      then
        "$VERBOSE" && echo "Building $arg.go" >&2
        subcmd_go build -o "$target_bin_path" "$arg.go"
      fi
    elif test -d ./cmd/"$arg"
    then
      local target_bin_path="$go_bin_dir_path"/"$arg""$exe_ext"
      if ! test -x "$target_bin_path" || newer ./cmd/"$arg" --than "$target_bin_path"
      then
        "$VERBOSE" && echo "Building ./cmd/$arg" >&2
        subcmd_go build -o "$target_bin_path" ./cmd/"$arg"
      fi
    else
      echo "No $arg.go or ./cmd/$arg found" >&2
      exit 1
    fi
  done
}

# Install Go tools.
task_install() {
  cd "$PROJECT_DIR"
  local go_sim_dir_path="$HOME"/go-bin
  mkdir -p "$go_sim_dir_path"
  rm -f "$go_sim_dir_path"/*
  for go_app_path in *.go cmd/*
  do
    if ! test -r "$go_app_path" && ! test -d "$go_app_path"
    then
      continue
    fi
    case "$go_app_path" in
      task.go|task-*.go) continue ;;
    esac
    name=$(basename "$go_app_path" .go)
    target_sim_path="$go_sim_dir_path"/"$name"
    if is_windows
    then
      pwd_backslash=$(echo "$PWD" | sed 's|/|\\|g')
      go_sim_dir_path_backslash=$(echo "$(realpath .)"/build | sed 's|/|\\|g')
      cat <<EOF > "$target_sim_path".cmd
@echo off
call $pwd_backslash\task build $name.go
$go_sim_dir_path_backslash\\$name.exe %*
EOF
    else
      cat <<EOF > "$target_sim_path"
#!/bin/sh
$PWD/task build "$name".go
exec $PWD/build/$name "\$@"
EOF
      chmod +x "$target_sim_path"
    fi
  done
}
