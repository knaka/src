#!/bin/sh
set -o nounset -o errexit

test "${guard_bcd6f78+set}" = set && return 0; guard_bcd6f78=-

. task.sh
. task-go.lib.sh

(
  for dir in .idea build
  do
    mkdir -p "$dir"
    set_sync_ignored "$dir"
  done
)

subcmd_build() ( # Build Go source files incrementally.
  chdir_script
  go_bin_dir_path=./build
  mkdir -p "$go_bin_dir_path"
  if test "${1+set}" != "set"
  then
    set -- *.go
  fi
  for go_file in "$@"
  do
    if ! test -r "$go_file"
    then
      continue
    fi
    name=$(basename "$go_file" .go)
    target_bin_path="$go_bin_dir_path"/"$name$(exe_ext)"
    if ! test -x "$target_bin_path" || newer "$go_file" --than "$target_bin_path"
    then
      # echo Building >&2
      subcmd_go build -o "$target_bin_path" "$name.go"
    fi
  done
)

task_install() { # Install Go tools.
  chdir_script
  go_sim_dir_path="$HOME"/go-bin
  mkdir -p "$go_sim_dir_path"
  rm -f "$go_sim_dir_path"/*
  for go_file in *.go
  do
    if ! test -r "$go_file"
    then
      continue
    fi
    case "$go_file" in
      task.go|task-*.go) continue ;;
    esac
    name=$(basename "$go_file" .go)
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
