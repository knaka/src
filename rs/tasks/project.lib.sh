# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_42ddef4-false}" && return 0; sourced_42ddef4=true

. ./utils.lib.sh
. ./rust.lib.sh

# Build
subcmd_build() {
  cargo build "$@"
}

depbuild() {
  newer Cargo.toml build.rs src/ --than target/debug/rsmain"$(exe_ext)" || return 0
  subcmd_build
}

# Dependency build
subcmd_depbuild() {
  depbuild "$@"
}

rsmain_run() {
  invoke "$PROJECT_DIR"/target/debug/rsmain "$@"
}

# Run rsmain
subcmd_rsmain__run() {
  rsmain_run "$@"
}

# Install shims
subcmd_install() {
  depbuild
  local subcmds_to_ignore=":list:nop:help:"
  local rs_bin_dir_path="$HOME"/rs-bin
  rm -fr "$rs_bin_dir_path"
  mkdir -p "$rs_bin_dir_path"
  local subcmd
  for subcmd in $(rsmain_run list)
  do
    echo "$subcmds_to_ignore" | grep -q ":$subcmd:" && continue
    if is_windows
    then
      local rs_bin_file_path="$rs_bin_dir_path"/"$subcmd".cmd
      cat <<EOF > "$rs_bin_file_path"
@echo off
"$PROJECT_DIR"\task.cmd rsmain:run "$subcmd" %* || exit /b !ERRORLEVEL!
EOF
    else
      local rs_bin_file_path="$rs_bin_dir_path"/"$subcmd"
      cat <<EOF > "$rs_bin_file_path"
#!/bin/sh
exec "$PROJECT_DIR"/task rsmain:run "$subcmd" "\$@"
EOF
      chmod +x "$rs_bin_file_path"
    fi
  done
}
