#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ LIB_UTILS_SH && return

# ==========================================================================
#region Environment variables.

# The initial working directory when the command was started.
: "${INITIAL_DIR=}"
: "${INITIAL_DIR:=${MISE_ORIGINAL_CWD:-}}" # https://mise.jdx.dev/tasks/toml-tasks.html
: "${INITIAL_DIR:=${INIT_CWD:-}}" # https://docs.npmjs.com/cli/v8/using-npm/scripts
: "${INITIAL_DIR:=$PWD}"
# Aliases
: "${ORIGINAL_CWD:=${INITIAL_DIR}}"
: "${ORIGINAL_PWD:=${INITIAL_DIR}}"
: "${INITIAL_PWD:=${INITIAL_DIR}}"

# Current project directory.
: "${PROJECT_DIR=}"
: "${PROJECT_DIR:=${MISE_PROJECT_ROOT:-}}"
: "${PROJECT_DIR:=$PWD}"

# The project directory where the task is defined.
: "${TASK_PROJECT_DIR=}"
: "${TASK_PROJECT_DIR:=${MISE_CONFIG_ROOT:-}}"
: "${TASK_PROJECT_DIR:=$PWD}"

# Verbosity.
: "${VERBOSE:=false}"

#endregion

# ==========================================================================
#region Basic utilities.

# shellcheck disable=SC2034
readonly ch_lf="
"

# shellcheck disable=SC2034
{
  readonly ch_tab="	"

  # Unit separator (US), Information Separator 1
  readonly ch_us=""
  readonly ch_is1="$ch_us"
  # Record separator (RS), Information Separator 2
  readonly ch_rs=""
  readonly ch_is2="$ch_rs"
  # Group separator (GS), Information Separator 3
  readonly ch_gs=""
  readonly ch_is3="$ch_gs"
  # File separator (FS), Information Separator 4
  readonly ch_fs=""
  readonly ch_is4="$ch_fs"
}

readonly SIGPIPE=13
# shellcheck disable=SC2034
readonly rc_sigpipe=$((128 + SIGPIPE))

# Guard against multiple calls. $1 is a unique ID
first_call() {
  eval "\${called_$1-false}" && return 1
  eval "called_$1=true"
}

# Check if stdout is tty.
is_terminal() {
  test -t 1
}

usv_called_6b2a1df="$ch_us"

# Run only once
run_once() {
  case "$usv_called_6b2a1df" in
    (*"$ch_us$*$ch_us"*)
      return 0
      ;;
  esac
  usv_called_6b2a1df="$usv_called_6b2a1df$*$ch_us"
  "$@"
}

# Check if external command exists in $PATH.
has_external_command() {
  # test -x "$(command -v "$1" 2>/dev/null)"
  # command which "$1" >/dev/null # `command` does not ignore builtins
  # env which "$1" >/dev/null
  which "$1" >/dev/null
}

: "${RESULT-}"

cmdbase_snake_() {
  RESULT=
  local s="$1"
  s="${s##*[/\\]}"
  s="${s%.sh}"
  s="${s%.bash}"
  local left
  while test -n "$s"
  do
    left=${s%%-*}
    test "$left" = "$s" && RESULT="$RESULT$s" && return
    RESULT="$RESULT$left"_
    s="${s#*-}"
  done
}

#endregion

# ==========================================================================
#region Temporary directory and cleaning up

: "${TEMP_DIR-}"

cleanup_cmds_054cf7c=:
prev_bashpid_73b382c=

# Traps are reset in subshells, so "cleanup_cmds" must be reset too.
# — Command Execution Environment (Bash Reference Manual) https://doc.guix.gnu.org/bash/latest/en/html_node/Command-Execution-Environment.html
# shellcheck disable=SC3028
reset_cleanup_cmds_if_new_subshell() {
  if test "$cleanup_cmds_054cf7c" != :
  then
    # Note that `trap -p ...` output inside a Bash subshell reflects the parent
    # shell's state, so it cannot be relied on for this check.
    if test -n "$prev_bashpid_73b382c" # Bash >= 4
    then
      if test "$prev_bashpid_73b382c" != "$BASHPID"
      then
        cleanup_cmds_054cf7c=:
      fi
    else # Others
      # Piping directly into grep would check the subshell's own trap (since a
      # pipeline stage runs in a subshell), so write the parent shell's trap
      # state to a temp file first and grep that instead.
      local temp_file
      temp_file="$(mktemp)"
      trap >"$temp_file"
      if ! grep EXIT "$temp_file" >/dev/null 2>&1
      then
        cleanup_cmds_054cf7c=:
      fi
      rm -f "$temp_file"
    fi
  fi
  test "${BASHPID+set}" = set && prev_bashpid_73b382c="$BASHPID"
  :
}

add_cleanup_5fbc8c7() {
  local should_append=false
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (append) should_append=true;;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  if test $# -ne 1
  then
    echo "prepend_cleanup takes one argument."
    return 1
  fi
  reset_cleanup_cmds_if_new_subshell
  if "$should_append"
  then
    cleanup_cmds_054cf7c="$cleanup_cmds_054cf7c; ${1}"
  else
    cleanup_cmds_054cf7c="${1}; $cleanup_cmds_054cf7c"
  fi
  # shellcheck disable=SC2064
  trap "$cleanup_cmds_054cf7c" EXIT
}

prepend_cleanup() {
  add_cleanup_5fbc8c7 "$@"
}

cleanup_temp() {
  rm -fr "$TEMP_DIR"
  unset TEMP_DIR
}

# Create a temporary directory and assign $TEMP_DIR env var
init_temp() {
  test "${TEMP_DIR+set}" && return 0
  TEMP_DIR="$(mktemp -d)"
  # shellcheck disable=SC2016
  prepend_cleanup cleanup_temp
}

register_temp_cleanup() {
  init_temp
}

cleanup_child_processes() {
  "${VERBOSE-false}" && echo Cleaning up child processes >&2
  trap : TERM
  if is_bbwin
  then
    # After catching TERM, doing something seems to fail.
    kill -TERM -$$
    return $?
  fi
  kill -TERM 0
}

# Register child-proceses cleanup trap handler.
register_child_cleanup() {
  first_call 5f719a3 || return 0
  add_cleanup_5fbc8c7 --append cleanup_child_processes
  trap : TERM
}

# Call the finalization function before `exec` which does not call trap function.
finalize() {
  reset_cleanup_cmds_if_new_subshell
  $cleanup_cmds_054cf7c
  cleanup_cmds_054cf7c=:
}

#endregion

# ==========================================================================
#region Platform detection. Detect platform without using subprocesses whenever possible, since subprocess creation is expensive and these functions are called frequently.

# Windows
is_windows() {
  test -d \\
}

# MSYS2 on Windows
is_msys2() {
  test -d \\ -a -d /proc
}

# BusyBox for Windows ash
is_bbwin() {
  test -d \\ -a ! -d /proc -a "${BBGLOBBING+set}" = set
}

is_macos() {
  test -f /System/Library/CoreServices/SystemVersion.plist
}

is_bsd() {
  is_macos || test -r /etc/rc.subr
}

is_mise() {
  test "${MISE_CONFIG_ROOT+set}" = set
}

is_linux() {
  # MSYS2 has /proc dir.
  test -d /proc -a -d /sys/kernel
  # Strict check
  # test -r /proc/sys/kernel/ostype \
  #   && read -r RESULT </proc/sys/kernel/ostype \
  #   && test "$RESULT" = Linux
}

is_debian() {
  test -f /etc/debian_version
}

is_alpine() {
  test -f /etc/alpine-release
}

is_bash_bin() {
  if test $# -eq 0
  then
    test "${BASH_VERSION+set}" = set
  else
    # shellcheck disable=SC3028
    # shellcheck disable=SC3054
    is_bash_bin && test "${BASH_VERSINFO[0]}" -ge "$1"
  fi
}

is_bash_posix() {
  # shellcheck disable=SC3010
  # shellcheck disable=SC3028
  is_bash_bin && [[ ":$SHELLOPTS:" = *:posix:* ]]
}

# Executable file extension.
exe_ext=
# shellcheck disable=SC2034
is_windows && exe_ext=".exe"

#endregion

# ==========================================================================
#region Directory stack.

psv_dirs_4c15d80=""

# `pushd` alternative.
push_dir() {
  local pwd="$PWD"
  if ! cd "$1" 2>/dev/null
  then
    echo "Directory does not exist: $1" >&2
    return 1
  fi
  psv_dirs_4c15d80="$pwd|$psv_dirs_4c15d80"
}

# `popd` alternative.
pop_dir() {
  if test -z "$psv_dirs_4c15d80"
  then
    echo "Directory stack is empty" >&2
    return 1
  fi
  local dir="${psv_dirs_4c15d80%%|*}"
  psv_dirs_4c15d80="${psv_dirs_4c15d80#*|}"
  cd "$dir" || return 1
}

#endregion

# ==========================================================================
#region Misc utilities.

# Canonicalize path
canon_path() {
  local target="$1"
  is_msys2 && target="$(cygpath -u "$target")"
  realpath "$target"
}

# Check if root directory
is_root_dir() {
  local dir="$1"
  dir="$(canon_path "$dir")"
  local parent_dir
  parent_dir="$(dirname "$dir")"
  test "$dir" = "$parent_dir"
}

# Check if a directory is empty.
is_dir_empty() {
  test -d "$1" || return 1
  ! test -e "$1"/* 2>/dev/null
}

# Wait for one or more servers to respond with HTTP 200. Checks each URL sequentially with a 60-second timeout per URL.
wait_for_http() {
  local url
  local max_attempts=60
  for url in "$@"
  do
    echo "Waiting for server at $url to be ready ..." >&2
    local attempts=0
    while :
    do
      # -s: silent mode (suppress progress/error output)
      # -o /dev/null: discard response body
      # -w "%{http_code}": print HTTP status code after transfers
      # 2>/dev/null: suppress stderr
      if curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null | grep -q "200"
      then
        echo "✓ Server is ready at $url" >&2
        break
      fi
      attempts=$((attempts + 1))
      if test $attempts -ge $max_attempts
      then
        echo "✗ Server at $url did not respond with 200 after $max_attempts seconds" >&2
        return 1
      fi
      sleep 1
    done
  done
}

if is_macos
then
  shuf() {
    sort -R "$@"
  }

  tac() {
    tail -r
  }
fi

# Get the space-separated nth (1-based) field.
field() {
  # Print 1-indexed n-th field of input lines.
  awk "{ print \$${1}} "
}

# Check if the file(s)/directories are newer than the destination.
newer() {
  local found_than=false
  local dest=
  local arg
  for arg in "$@"
  do
    shift
    if test "$arg" = "--than"
    then
      found_than=true
    elif $found_than
    then
      dest="$arg"
    else
      set -- "$@" "$arg"
    fi
  done
  if test -z "$dest"
  then
    echo "Missing --than option" >&2
    exit 1
  fi
  if test "$#" -eq 0
  then
    echo "No source files specified" >&2
    exit 1
  fi
  # If the destination does not exist, sources are considered newer than the destination.
  if ! test -e "$dest"
  then
    echo "Destination does not exist: $dest" >&2
    return 0
  fi
  # If the destination is a directory, the newest file in the directory is used.
  if test -d "$dest"
  then
    if is_bsd
    then
      dest="$(find "$dest" -type f -exec stat -l -t "%F %T" {} \+ | cut -d' ' -f6- | sort -n | tail -1 | cut -d' ' -f3)"
    else
      dest="$(find "$dest" -type f -exec stat -Lc '%Y %n' {} \+ | sort -n | tail -1 | cut -d' ' -f2)"
    fi
  fi
  if test -z "$dest"
  then
    echo "No destination file found" >&2
    return 0
  fi
  test -n "$(find "$@" -newer "$dest" 2>/dev/null)"
}

# Returns true if no source file is newer than the destination file.
older() {
  ! newer "$@"
}

# Open the URL in the browser.
browse() {
  if is_windows
  then
    PowerShell -NoProfile -Command "Start-Process '$1'"
    return $?
  fi
  if is_macos
  then
    open "$1"
    return $?
  fi
  xdg-open "$1"
}

# Create a file from the standard input if it does not exist.
ensure_file() {
  local file_path="$1"
  if test -f "$file_path"
  then
    echo "File $file_path already exists. Skipping creation." >&2
    return 0
  fi
  echo "Creating file $file_path." >&2
  mkdir -p "$(dirname "$file_path")"
  cat >"$file_path"
}

# Left/Right-Word-Boundary regex is incompatible with BSD sed // re_format(7) https://man.freebsd.org/cgi/man.cgi?query=re_format&sektion=7
lwb='\<'
rwb='\>'

# shellcheck disable=SC2034
if is_bsd
then
  lwb='[[:<:]]'
  rwb='[[:>:]]'
fi

# [<file>] Read the file and print substituting environment variables. Unlike envsubst(1), this tries to expand undefined environment variables and fails for that.
env_subst() {
  if test "$#" -gt 0
  then
    local template_file="$1"
    eval "cat <<EOF
$(cat "$template_file")
EOF"
  else
    eval "cat <<EOF
$(cat)
EOF"
  fi
}

# [regex replacement ...] Substitute text that matches regex patterns in stdin input. Takes pairs of regex/replacement arguments and applies them via sed(1).
resubst() {
  local step=2
  local i=0 n=$(($# / step))
  while test "$i" -lt "$n"
  do
    set -- "$@" -e "s${ch_us}$1${ch_us}$2${ch_us}g"
    shift $step
    i=$((i + 1))
  done
  sed "$@"
}

filter_log() {
  awk '{printf "\r%s\n", $0}'
}

#endregion
