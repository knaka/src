#!/bin/sh
test "${guard_b6c071a+set}" = set && return 0; guard_b6c071a=-

. ./task.sh
. ./edit.lib.sh

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
