#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ c75cafd && return

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../../.lib "$OLDPWD" "$@"
. ../../.lib/utils.sh
. ../../.lib/edit.sh
cd "$3" || exit; shift 3

# Generate a Sh-inlined batch script that embeds shell code for Windows
#
# This function creates a Windows batch (.cmd) wrapper script that:
#   1. Contains shell script source code embedded at the end of the file
#   2. Extracts the embedded script to a temp file at runtime
#   3. Executes the script via shell interpreter with provided arguments
#   4. Cleans up temporary files after execution
#
# Options:
#   --sh-file FILE    Shell script file to embed (required)
#   --output FILE     Output path for generated batch script (required)
#
# Example:
#   gen_sh_inlined --sh-file=./foo.sh --output=./foo-sh.cmd
gen_sh_inlined() {
  local sh_file=
  local output=
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (sh-file) sh_file="$OPTARG";;
      (output) output="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  (
    extract_before a5f342b task.cmd
    cat <<'EOF'
set exit_code=1

:unique_temp_loop
set "temp_dir_path=%TEMP%\%~n0-%RANDOM%"
if exist "!temp_dir_path!" goto unique_temp_loop
mkdir "!temp_dir_path!" || goto :exit
call :to_short_path "!temp_dir_path!"
set temp_dir_spath=!short_path!

for /f "usebackq tokens=1 delims=:" %%i in (`findstr /n /b :embed_53c8fd5 "%~f0"`) do set n=%%i
set tempfile=!temp_dir_spath!\!name!.sh
more +%n% "%~f0" > !tempfile!

!cmd_path! sh "!tempfile!" %* || goto :exit
set exit_code=0

:exit
if exist !temp_dir_spath! (
  del /q !temp_dir_spath!
)
exit /b !exit_code!

:to_short_path
set "input_path=%~1"
for %%i in ("%input_path%") do set "short_path=%%~si"
exit /b
goto :eof

:embed_53c8fd5
EOF
    cat "$sh_file"
  ) >"$output"
}

# Generate a Sh-inlined sample .cmd file.
task_hello_cmd__gen() {
  gen_sh_inlined \
    --sh-file=./misc/hello.sh \
    --output=./misc/hello-sh.cmd
}

gen_sourced() {
  local sh_file=""
  local output=""
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (sh-file) sh_file="$OPTARG";;
      (output) output="$OPTARG" ;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  ./expand-sh.awk "$sh_file" >"$output"
}

# Generate sourced sh sample.
task_hello_sourced_sh__gen() {
  gen_sourced \
    --sh-file=./_sh-hello.sh \
    --output=./misc/expanded-hello.sh
}

# ==========================================================================
#region Installation.

gen_bash_script() { cat <<EOF
#!/usr/bin/env sh
cd "$PROJECT_DIR" || exit
exec mise exec -- bash _chdir.bash "\$OLDPWD" "$PROJECT_DIR"/"$file" "\$@"
EOF
}

gen_sh_script() { cat <<EOF
#!/usr/bin/env sh
cd "$PROJECT_DIR" || exit
exec mise exec -- sh _chdir.sh "\$OLDPWD" "$PROJECT_DIR"/"$file" "\$@"
EOF
}

gen_direct_sh_script() { cat <<EOF
#!/usr/bin/env sh
exec sh "$PROJECT_DIR"/"$file" "\$@"
EOF
}

gen_py_sh_script() { cat <<EOF
#!/usr/bin/env sh
cd "$PROJECT_DIR" || exit
exec mise exec -- python _chdir.py "\$OLDPWD" "$PROJECT_DIR"/"$file" "\$@"
EOF
}

# Install shell scripts.
task_install() {
  push_dir "$PROJECT_DIR" || exit 1
  local bin_dir_path="$HOME"/bin
  mkdir -p "$bin_dir_path"
  if test "${executed_thru_t_bb789ec+set}" = set
  then
    echo "In a Windows environment, $bin_dir_path/t.sh is not replaced because it is locked. Run ./task.cmd instead." >&2
    return 1
  fi
  rm -fr "${bin_dir_path:?}"/*
  local file
  for file in *.sh
  do
    test -e "$file" || continue
    case "$file" in
      (_*) continue;;
    esac
    local name
    case "$file" in
      (*.direct.sh)
        name="${file%.direct.sh}"
        gen_direct_sh_script >"$bin_dir_path"/"$name"
        ;;
      (*)
        name="${file%.sh}"
        gen_sh_script >"$bin_dir_path"/"$name"
        ;;
    esac
    chmod +x "$bin_dir_path"/"$name"
    if is_windows
    then
      # Create Busybox ash shim.
      cat task.cmd >"$bin_dir_path"/"$name".cmd
    fi
  done
  for file in *.bash
  do
    test -e "$file" || continue
    case "$file" in
      (_*) continue;;
    esac
    local name="${file%.bash}"
    gen_bash_script >"$bin_dir_path"/"$name"
    chmod +x "$bin_dir_path"/"$name"
    if is_windows
    then
      # Create Busybox ash shim.
      cat task.cmd >"$bin_dir_path"/"$name".cmd
    fi
  done
  for file in *.py
  do
    test -e "$file" || continue
    case "$file" in
      (_*) continue;;
    esac
    local name="${file%.py}"
    gen_py_sh_script >"$bin_dir_path"/"$name"
    chmod +x "$bin_dir_path"/"$name"
    if is_windows
    then
      # Create Busybox ash shim.
      cat task.cmd >"$bin_dir_path"/"$name".cmd
    fi
  done
  pop_dir
}

#endregion
