#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 0648daa && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../../.lib "$@"
. ../../.lib/utils.sh
. ../../.lib/commands.sh
shift 2
cd "$1" || exit; shift

chezmoi_source_dir="$PROJECT_DIR"/chezmoi-source

# Install dotfiles to $HOME/
task_dotfiles__install() {
  chezmoi --source="$chezmoi_source_dir" apply
}

# Update karabiner.json
task_karabiner_json__update() {
  newer karabiner.yaml --than karabiner.json || return 0
  echo "Updating karabiner.json" >&2
  yj -yj karabiner.yaml >karabiner.json
}

# Install karabiner.json to $HOME/.config/karabiner as hard link
task_karabiner_json__install() {
  is_macos || return 0
  mkdir -p "$HOME"/.config/karabiner
  task_karabiner_json__update
  echo "Hard linking karabiner.json" >&2
  ln -f karabiner.json "$HOME"/.config/karabiner/karabiner.json
}

# Install PS1 profile.
task_ps1__install() {
  is_windows || return 0
  local profile_path
  # PowerShell < 6
  # shellcheck disable=SC2016
  profile_path="$(powershell.exe -Command 'Write-Output $PROFILE')"
  mkdir -p "$(dirname "${profile_path}")"
  ln -sf "$(realpath ./ps1/profile.ps1)" "${profile_path}"
  # PowerShell >= 6
  # shellcheck disable=SC2016
  profile_path="$(pwsh.exe -Command 'Write-Output $PROFILE')"
  mkdir -p "$(dirname "${profile_path}")"
  ln -sf "$(realpath ./ps1/profile.ps1)" "${profile_path}"
}

# Install configuration files.
task_install() {
  call_task task_dotfiles__install
  call_task task_karabiner_json__install
  call_task task_ps1__install
}

# Generate Gemini stuff from Claude configurations.
task_gemini__gen() {
  local claude_commands_dir="$chezmoi_source_dir"/dot_claude/commands
  local gemini_commands_dir="$chezmoi_source_dir"/dot_gemini/commands
  mkdir -p "$gemini_commands_dir"
  local in_file out_file description prompt
  for in_file in "$claude_commands_dir"/*.md
  do
    local base="${in_file##*/}"
    base="${base%.md}".toml
    out_file="$gemini_commands_dir"/"$base"
    description="$(yq --front-matter=extract '.description' "$in_file")"
    prompt="$(sed '1{/^---$/!q;};1,/^---$/d' "$in_file")"
    jq -n \
      --arg description "$description" \
      --arg prompt "$prompt" \
      '.description = $description | .prompt = $prompt' \
    | yj -jt \
    >"$out_file"
  done
}
