#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b425ed1-false}" && return 0; sourced_b425ed1=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

emlr_help() {
  cat <<EOF
Format Delimiter-Separated Values files using the MLR (Miller https://miller.readthedocs.io/ ) "put" command. If the input file has a ".cmt.{csv,tsv}" extension, an embedded script in its comment lines prefixed with "# +MLR: ..." or "# +MILLER: ..." will be used. Otherwise, if a script file named "foo.csv.mlr" exists for "foo.csv", it will be used instead.

Script file matching supports wildcard patterns using '%' as a placeholder:
  - For "data-123.csv", the script "data-%.csv.mlr" will match
  - For "report-2024-01.csv", the script "report-%-%.csv.mlr" will match
  - Exact matches (e.g., "foo.csv.mlr" for "foo.csv") take precedence over wildcard matches

Usage: ${0##*/} [options] [file...]

Options:
  -h, --help
    Display this help message and exit.
  -i, --inplace
    Modify the DSV file in place.
EOF
}

emlr() {
  local inplace=false
  OPTIND=1; while getopts _hiI-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (h|help)
        emlr_help
        exit 0
        ;;
      (i|inplace)
        inplace=true
        ;;
      (\?) exit 1;;
      (*)
        echo "Unexpected option: $OPT" >&2;
        emlr_help
        exit 1
        ;;
    esac
  done
  shift $((OPTIND-1))

  local file_path
  local file_ext
  local script_file_path
  for file_path in "$@"
  do
    if ! test -f "$file_path"
    then
      echo "File not found: $file_path" >&2
      exit 1
    fi
    case "$file_path" in
      (*.cmt.csv|*.cmt.tsv)
        file_ext="${file_path##*.}"
        init_temp_dir
        script_file_path="$TEMP_DIR"/script.mlr
        sed -n -E -e 's/^# \+MLR: *(.*)/\1/p' -e 's/^# \+MILLER: *(.*)/\1/p' "$file_path" >"$script_file_path"
        if ! test -s "$script_file_path"
        then
          echo "No MLR script found in $file_path." >&2
           
        fi
        ;;
      (*.csv|*.tsv)
        file_ext="${file_path##*.}"
        script_file_path="$file_path".mlr
        # First, try exact match
        if ! test -r "$script_file_path"
        then
          # Try wildcard matching with %
          local base_name="${file_path##*/}"
          local dir_name="${file_path%/*}"
          if test "$dir_name" = "$file_path"
          then
            dir_name="."
          fi
          script_file_path=""
          # Look for .mlr files with % in the same directory
          local pattern_file
          for  pattern_file in "$dir_name"/*%*.*.mlr
          do
            if ! test -f "$pattern_file"
            then
              continue
            fi
            # Convert % to * for shell pattern matching
            local pattern_name="${pattern_file##*/}"
            pattern_name="${pattern_name%.mlr}"
            local shell_pattern
            shell_pattern=$(printf '%s\n' "$pattern_name" | sed 's/%/*/g')
            # Test if base_name matches the pattern
            # shellcheck disable=SC2254
            case "$base_name" in
              ($shell_pattern)
                script_file_path="$pattern_file"
                break
                ;;
            esac
          done
          if test -z "$script_file_path"
          then
            echo "No MLR script found for $file_path." >&2
            continue
          fi
        fi
        ;;
      (*)
        echo "Unsupported file type: $file_path" >&2
        exit 1
        ;;
    esac
    # Skip if file is empty or has only header line
    local line_count
    line_count=$(grep --count --invert-match '^#' "$file_path" || echo 0)
    if test "$line_count" -le 1
    then
      echo "Skipping $file_path: empty or header only" >&2
      continue
    fi
    # Global options for Miller
    # `--lazy-quotes` to avoid error double quotes in comments
    set -- --i"$file_ext" --o"$file_ext" --pass-comments
    if "$inplace"
    then
      set -- "$@" -I
    fi
    # Subcommand and its arguments
    #   --ragged: accept ragged lines
    set -- "$@" --ragged put -f "$script_file_path" "$file_path"
    mlr "$@"
  done
}

case "${0##*/}" in
  (emlr.sh|emlr)
    set -o nounset -o errexit
    emlr "$@"
    ;;
esac
