#!/usr/bin/env sh
set -- _BIN_TOUCHSH_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

# Generate Bourne shell script scaffold.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
shift 2; set -- _SCRDIR . "$@" # shpp:sources_chdir
. ./rand7.sh 
cd "$3" || exit; shift 3 # /shpp:sources

# # vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# # shellcheck shell=sh

gen_header_49df118() { cat <<'EOF'
#!/usr/bin/env sh
set -- _BIN_TOUCHSH_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard
EOF
}

gen_source_block_8d319a6() { cat <<'EOF'
if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources
EOF
}

gen_body_e1af234() { cat <<EOF
${func_name}() {
  echo "Function \"${func_name}\" is not implemented yet."
}
EOF
}

gen_call_33c667a() {
local name="$func_name"
if test "$func_name" != "$call_name"
then
  name="$call_name"
fi
cat <<EOF
if eval test '"\$0" = "\${BASH_SOURCE-}"' || case ".\${0##*[/\\]}." in (*.${name}.*) ;; (*) false;; esac
then
  set -o nounset -o errexit
  ${func_name} "\$@"
fi
EOF
}

gen_tasks_body_f774151() { cat <<EOF
case "\${0##*/}" in
  (${pattern})
    set -o nounset -o errexit
    "\$@"
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
  local call_name
  call_name="${file_base%.sh}"
  local pattern
  # local has_ext
  case "$file_base" in
    (*.sh)
      pattern="*,$file_base,*|*,${file_base%.sh},*"
      # has_ext=true
      ;;
    (*)
      pattern="*,$file_base,*"
      # has_ext=false
      ;;
  esac
  local is_lib
  case "$file_base" in
    (*.sh|*.libsh|*.shlib)
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
    # if ! "$is_lib" && ! "$has_ext"
    # then
    #   echo '#!/usr/bin/env sh'
    # fi
    gen_header_49df118 | sed -e "s/@UNIQUE_ID@/$unique_id/g"
    echo
    if "$is_lib"
    then
      # gen_lib_source_block_bba821b
      gen_source_block_8d319a6
      echo
      gen_body_e1af234
      echo
      gen_call_33c667a
    elif "$is_tasks"
    then
      gen_source_block_8d319a6
      echo
      gen_tasks_body_f774151
    else
      gen_source_block_8d319a6
      echo
      gen_body_e1af234
      echo
      gen_call_33c667a
    fi
  } \
  | if "$is_stdout"
    then
      cat
    else
      cat >"$path"
    fi
  # if ! "$is_stdout" && ! "$is_lib" && ! "$has_ext"
  if ! "$is_stdout"
  then
    chmod +x "$path"
  fi
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (touchsh.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  touchsh "$@"
fi
