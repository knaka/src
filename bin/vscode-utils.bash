#!/usr/bin/env bash
set -- _6bd1e83 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/version.sh
popd >/dev/null || exit

vscode_apply_patch() {
  local ext_id="$1"
  local rel_path="$2"
  local user_exts_dir="$HOME"/.vscode/extensions
  local ext_dir
  ext_dir="$(
    find "$user_exts_dir" -maxdepth 1 -name "$ext_id-*" \
    | sort_version -r \
    | head -1
  )"
  if test -z "$ext_dir"
  then
    echo c8a3157 >&2
    return 1
  fi
  patch --backup --directory="$ext_dir"/"$rel_path"
}
