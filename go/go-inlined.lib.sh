# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f82c335-false}" && return 0; sourced_f82c335=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
shift 2
cd "$1" || exit 1; shift

# Generate a Go-inlined shell script that embeds and compiles Go code
#
# This function creates a shell wrapper script that:
#   1. Contains Go source code from a main file
#   2. Compiles the Go code on first run (cached in $GOPATH/bin)
#   3. Executes the compiled binary with provided arguments
#
# The generated script will automatically recompile when the source changes.
#
# Options:
#   --main-file=FILE  Go source file containing main package (required)
#   --output=FILE     Output path for generated shell script (required)
#
# Example:
#   gen_go_inlined --main-file=cmd.go --output=cmd.sh
#
gen_go_inlined() {
  local main_file=
  local output=
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (main-file) main_file="$OPTARG";;
      (output) output="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if test -z "$main_file" || test -z "$output"
  then
    echo "Missing required options" >&2
    return 1
  fi

  if older "$main_file" --than "$output"
  then
    echo "No need to update $output" >&2
    return 0
  fi

  (
    cat task.sh
    # Remove "source"s from go.lib.sh.
    sed -e 's/^\. .*//' go.lib.sh
    cat <<'EOF'
init_temp_dir
gopath="${GOPATH:-$HOME/go}"
mkdir -p "$gopath"/bin
unique_name="$(sha256sum "$0" | sed -E -e 's/^(.......).*/\1/')"
cmd_path="$gopath"/bin/inlined-"$unique_name$exe_ext"
if newer "$0" --than "$cmd_path"
then
  (
    main_file_path="$TEMP_DIR"/main.go
    cat <<'EMBED_FAA58B3' >"$main_file_path"
EOF
    cat "$main_file"
    cat <<'EOF'
EMBED_FAA58B3
    echo Compiling "$0". >&2
    go build -o "$cmd_path" "$main_file_path"
  )
fi
rm -fr "$TEMP_DIR"
exec "$cmd_path" "$@"
EOF
  ) >"$output"
  chmod 0755 "$output"
}
