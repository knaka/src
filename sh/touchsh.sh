#!/usr/bin/env sh
# vim: set filetype=sh :
# shellcheck shell=sh
"${sourced_10bd1b4-false}" && return 0; sourced_10bd1b4=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
. ./rand7.sh 
cd "$1" || exit 1; shift 2

gen_header_49df118() { cat <<EOF
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"\${sourced_${unique_id}-false}" && return 0; sourced_${unique_id}=true
EOF
}

gen_lib_source_block_bba821b() { cat <<'EOF'
set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR . "$@"
shift 2
cd "$1" || exit 1; shift
EOF
}

gen_source_block_8d319a6() { cat <<'EOF'
set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
shift 2
cd "$1" || exit 1; shift 2
EOF
}

gen_body_e1af234() { cat <<EOF
${func_name}() {
  echo "Function \"${func_name}\" is not implemented yet."
}

case "\${0##*/}" in
  (${pattern})
    set -o nounset -o errexit
    ${func_name} "\$@"
    ;;
esac
EOF
}

gen_tasks_f774151() { cat <<'EOF'
case "${0##*/}" in
  (tasks-*)
    set -o nounset -o errexit
    "$@"
    ;;
esac
EOF
}

touchsh() {
  test $# = 0 && set -- -
  local path="$1"
  local is_stdout
  if test "$path" = -
  then
    is_stdout=true
  else
    is_stdout=false
    if test -s "$path"
    then
      echo "File \"$path\" already exists and has size greater than 0. Only touching it." >&2
      touch "$path"
      return
    fi
  fi
  local unique_id
  unique_id="$(rand7)"
  local file_base
  if test "$path" = -
  then
    file_base="x$unique_id.sh"
  else
    file_base="$path"
    file_base="${file_base##*/}"
    file_base="${file_base##*\\}"
  fi
  local func_name
  func_name="$(echo "${file_base%.sh}" | tr '-' '_')"
  local pattern
  local has_ext
  case "$file_base" in
    (*.sh)
      pattern="$file_base|${file_base%.sh}"
      has_ext=true
      ;;
    (*)
      pattern="$file_base"
      has_ext=false
      ;;
  esac
  local is_lib
  case "$file_base" in
    (*.lib.sh|*.libsh|*.shlib)
      is_lib=true
      echo Generating library shell script. >&2
      ;;
    (*)
      is_lib=false
      echo Generating shell script. >&2
      ;;
  esac
  local is_tasks
  case "$file_base" in
    (tasks-*) is_tasks=true;;
    (*) is_tasks=false;;
  esac
  {
    if ! "$is_lib" && ! "$has_ext"
    then
      echo '#!/usr/bin/env sh'
    fi
    gen_header_49df118
    echo
    if "$is_lib"
    then
      gen_lib_source_block_bba821b
      echo
    elif "$is_tasks"
    then
      gen_source_block_8d319a6
      echo
      gen_tasks_f774151
    else
      gen_source_block_8d319a6
      echo
      gen_body_e1af234
    fi
  } \
  | if "$is_stdout"
    then
      cat
    else
      cat >"$path"
    fi
  if ! "$is_stdout" && ! "$is_lib" && ! "$has_ext"
  then
    chmod +x "$1"
  fi
}

case "${0##*/}" in
  (touchsh|touchsh.sh)
    set -o nounset -o errexit
    touchsh "$@"
    ;;
esac
