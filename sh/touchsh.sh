#!/usr/bin/env sh
# vim: set filetype=sh :
# shellcheck shell=sh
test "${sourced_723152a:+}" = true && return 0; sourced_723152a=true
set -o nounset -o errexit

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./rand7.sh 
cd "$1" || exit 1; shift 2

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

if test -s "$1"
then
  echo "File $1 already exists and has size greater than 0. Only touching it." >&2
  touch "$1"
  exit 0
fi

unique_id="$(rand7)"
func_name=
base_name=
if test "$1" = "-"
then
  base_name="x${unique_id}.sh"
else
  base_name="${1##*/}"
fi
base_name_wo_sh="${base_name%.sh}"
func_name="$(echo "$base_name_wo_sh" | tr '-' '_')"
cmd_matching_pattern="$base_name"
has_ext=false
if test "$base_name" != "$base_name_wo_sh"
then
  has_ext=true
  cmd_matching_pattern="$cmd_matching_pattern|$base_name_wo_sh"
fi

# echo 75ca5dc: "${base_name%.lib.sh}" >&2
# $(test "${base_name%.lib.sh}" = "${base_name}" && printf '#!/usr/bin/env sh\n')

if test "$1" = "-"
then
  exec 3>&1
else
  exec 3>"$1"
fi

is_lib_sh=false
if \
  test "${base_name%.shlib}" != "${base_name}" || \
  test "${base_name%.lib.sh}" != "${base_name}" || \
  test "${base_name%.lib.sh}" != "${base_name}"
then
  echo Creating library shell script. >&2
  is_lib_sh=true
else
  echo Creating executable shell script. >&2
fi

(
if ! "$is_lib_sh"
then
  echo '#!/usr/bin/env sh'
fi

cat <<EOF
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"\${sourced_${unique_id}-false}" && return 0; sourced_${unique_id}=true
EOF

echo

if "$is_lib_sh"
then
  cat <<'EOF'
# set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
# set -- _LIBDIR . "$@"
# shift 2
# cd "$1" || exit 1; shift
EOF
else
cat <<'EOF'
# set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
# set -- _LIBDIR . "$@"
# shift 2
# cd "$1" || exit 1; shift 2
EOF
fi

if ! "$is_lib_sh"
then
  cat <<EOF

${func_name}() {
  :
}

case "\${0##*/}" in
  (${cmd_matching_pattern})
    set -o nounset -o errexit
    ${func_name} "\$@"
    ;;
esac
EOF
fi
) >&3

if test "$1" != "-" && ! "$is_lib_sh" && ! "$has_ext"
then
  chmod +x "$1"
fi

# Other options:
#   set -o monitor # For job control
#   set -o xtrace # For debugging
#   set -o pipefail # For error handling in pipelines in Bash
