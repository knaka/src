#!/bin/sh
set -o nounset -o errexit

test "${guard_bd3d431+set}" = set && return 0; guard_bd3d431=x

. ./task.sh

mkdir_sync_ignored build
mkdir_sync_ignored .stack-work

set_ghcup_env() {
  test "${guard_e7bac94+set}" = set && return 0; guard_e7bac94=x
  PATH="$(ghcup whereis bindir):$PATH"
  export PATH
  # install_pkg \
  #   --cmd=ghcup \
  #   --brew-id=ghcup \
  #   --winget-id=ghcup \
  #   --winget-cmd-path=C:/foobar/ghcup.exe
}

subcmd_ghcup() { # Run the `ghcup` command. 
  set_ghcup_env
  cross_exec ghcup "$@"
}

subcmd_stack() { # Run the `stack` command. 
  set_ghcup_env
  if ! type stack >/dev/null 2>&1
  then
    subcmd_ghcup install stack
  fi
  cross_exec stack "$@"
}

subcmd_ghc() {
  subcmd_stack exec ghc "$@"
}

subcmd_ghci() {
  subcmd_stack exec ghci "$@"
}

# --------------------------------------------------------------------------
# 以下、別ファイルへ

# shellcheck disable=SC2120
subcmd_build() { # Build the project.
  (
    cd "$(dirname "$0")"
    sh stack-cmd.sh build hsprj:main-exe "$@"
    cmd_path="$(sh stack-cmd.sh exec which main-exe)"
    # It is MSYS2 path in Windows. `cygpath` is not in $PATH because it is installed by Stack.
    if is_windows
    then
      cmd_path="$(sh stack-cmd.sh exec cygpath -- --windows "$cmd_path")"
    fi
    mkdir -p ./build/
    cp -a "$cmd_path" ./build/
    echo Copied the command to: ./build/"$(basename "$cmd_path")" >&2
  )
}

subcmd_run() { 
  if ! type "$(dirname "$0")"/build/main-exe > /dev/null 2>&1
  then
    # shellcheck disable=SC2119
    subcmd_build
  fi
  exec "$(dirname "$0")"/build/main-exe "$@"
} 

task_install() { # Installs Haskell shim entries.
  bin_dir_path="$HOME/hs-bin"
  mkdir -p "$bin_dir_path"
  rm -f "$bin_dir_path"/*
  subcmd_run "subcmds" | while read -r line 
  do
    subcmd="$(echo "$line" | sed -r -e 's/^([[:alnum:]-]+)\s.*/\1/')"
    if is_windows
    then
      bin_file_path="$bin_dir_path"/"$subcmd".cmd
      cat <<EOF > "$bin_file_path"
@echo off
"$PWD"\task.cmd run $subcmd %* 
EOF
    else
      bin_file_path="$bin_dir_path"/"$subcmd"
      cat <<EOF > "$bin_file_path"
#!/bin/sh
exec "$PWD"/task run $subcmd "\$@" 
EOF
    fi
    chmod +x "$bin_file_path"
  done
}
