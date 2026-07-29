#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_YAML2JSON_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # /shpp:sources

yaml2json_help() { cat <<EOF
Convert YAML to JSON.

Usage: ${0##*/} [options] [file...]

Options:
  -h, --help
    Show this help message and exit.
  -i, --inplace
    Convert to the JSON file in place.
  -I, --inplace-existing
    Convert to the JSON file in place only if it exists.
EOF
}

yaml2json() {
  local inplace=false
  local only_if_existing=false
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
        yaml2json_help
        exit 0
        ;;
      (i|inplace)
        inplace=true
        ;;
      (I|inplace-existing)
        inplace=true
        only_if_existing=true
        ;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if "$inplace"
  then
    if test $# -eq 0
    then
      echo "No files specified for inplace conversion" >&2
      exit 1
    fi
    local file
    local json_file
    for file in "$@"
    do
      if test ! -r "$file"
      then
        echo "File not found: $file" >&2
        exit 1
      fi
      json_file="${file%.*}.json"
      if "$only_if_existing" && ! test -r "$json_file"
      then
        echo "File not found: $json_file. Skikpping." >&2
        continue
      fi
      if test -r "$json_file"
      then
        chmod +w "$json_file"
      fi
      yq -o json "$file" >"$json_file"
      chmod -w "$json_file"
    done
  else
    yq -o json "$@"
  fi
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (yaml2json.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  yaml2json "$@"
fi
