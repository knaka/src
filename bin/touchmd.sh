#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_TOUCHMD_SH && return # shpp:source_guard
set -o nounset -o errexit

# Create Markdown file with front-matter attributes.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@" # shpp:begin_source
. ./rand7.sh
. ./date-iso.sh
cd "$3" || exit; shift 3 # shpp:end_source

force=false
OPTIND=1; while getopts f-: OPT
do
  if test "$OPT" = "-"
  then
    OPT="${OPTARG%%=*}"
    # shellcheck disable=SC2030
    OPTARG="${OPTARG#"$OPT"}"
    OPTARG="${OPTARG#=}"
  fi
  case "$OPT" in
    (f|force) force=true;;
    (\?) usage; exit 2;;
    (*) echo "Unexpected option: $OPT" >&2; exit 2;;
  esac
done
shift $((OPTIND-1))

if ! test "${1+set}" = set
then
	set -- -
fi

for file in "$@"
do
	if test "$file" = -
	then
		:
	elif test -e "$file" && ! $force
	then
		echo "$file exists. Just touching." >&2
		touch "$file"
		continue
	else
		exec 1>"$file"
	fi
	cat <<-EOF
		---
		id: "$(rand7)"
		title: "Markdown ($(date_iso))"
		tags: []
		created_at: "$(date_iso)"
		---

		# Markdown ($(date_iso))

		---
EOF
done
