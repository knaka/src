# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_c572edd-false}" && return 0; sourced_c572edd=true

. ./task.sh
. ./task-go.lib.sh
. ./task-embedded-go.lib.sh

task_go_hello__gen() { # Generate go-embedded sample scripts.
  local out_sh=go-hello
  subcmd_go__embedded__sh__gen \
    --url="https://raw.githubusercontent.com/knaka/src/go/$out_sh" \
    --main-go=./hello.go \
    --template-sh=./embedded-go \
    --out-sh=./"$out_sh"
  local out_cmd=go-hello.cmd
  subcmd_go__embedded__cmd__gen \
    --url="https://raw.githubusercontent.com/knaka/src/go/$out_cmd" \
    --main-go=./hello.go \
    --template-cmd=./embedded-go.cmd \
    --out-cmd=./"$out_cmd"
}

task_gen() { # Generate files.
  task_go_hello__gen
}

subcmd_build() ( # Build Go source files incrementally.
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
      local target_bin_path="$go_bin_dir_path"/"$arg""$(exe_ext)"
      if ! test -x "$target_bin_path" || newer "$go_file" --than "$target_bin_path"
      then
        "$VERBOSE" && echo "Building $arg.go" >&2
        subcmd_go build -o "$target_bin_path" "$arg.go"
      fi
    elif test -d ./cmd/"$arg"
    then
      local target_bin_path="$go_bin_dir_path"/"$arg""$(exe_ext)"
      if ! test -x "$target_bin_path" || newer ./cmd/"$arg" --than "$target_bin_path"
      then
        "$VERBOSE" && echo "Building ./cmd/$arg" >&2
        subcmd_go build -o "$target_bin_path" ./cmd/"$arg"
      fi
    else
      echo "No $arg.go or ./cmd/$arg" >&2
      exit 1
    fi
  done
)

task_install() { # Install Go tools.
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

task_install_bin() ( # Install the tools implemented in Go.
  gopath="$HOME"/go
  bin_dir_path="$gopath"/bin
  mkdir -p "$bin_dir_path"
  repos_dir_path="$HOME"/repos
  mkdir -p "$repos_dir_path"
  exe_ext=
  if is_windows
  then
    exe_ext=.exe
  fi
  # shellcheck disable=SC2043
  for repo_path in \
    "https://github.com/knaka/peco.git cmd/peco"
  do
    repo=${repo_path%% *}
    path=${repo_path#* }
    cmd_name="$(basename "$path")"
    if test -z "$cmd_name"
    then
      cmd_name=$(basename "$repo" .git)
    fi
    if type "$bin_dir_path"/"$cmd_name" > /dev/null 2>&1
    then
      continue
    fi
    # repo_dir_path="$repos_dir_path"/
    repo_dir_name="$repo"
    repo_dir_name=${repo_dir_name%%.git}
    repo_dir_name=${repo_dir_name##https://}
    repo_dir_path="$repos_dir_path"/"$repo_dir_name"
    if ! test -d "$repo_dir_path"
    then
      subcmd_go run ./go-git-clone.go "$repo" "$repo_dir_path"
    fi
    (
      cd "$repo_dir_path" || exit 1
      subcmd_go build -o "$bin_dir_path"/"$cmd_name$exe_ext" ./"$path"
    )
  done
)
