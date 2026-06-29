# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_loaded() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _loaded 9989bcc && return 0

# Generate Bash shell script scaffold.

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
. ./rand7.bash
popd >/dev/null || exit 1

# gen_header_bf7ac7d() { cat <<EOF
# # vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# # shellcheck shell=bash
# "\${sourced_${unique_id}-false}" && return 0; sourced_${unique_id}=true
# EOF
# }

gen_header_bf7ac7d() { cat <<EOF
# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "\${_ids-}" in (*\$1*) ;; (*) _ids="\$1,\${_ids-}"; false;; esac; }; _ $unique_id && return 0
EOF
}

gen_source_block_67741b4() { cat <<'EOF'
# pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
# . ./.lib/utils.bash
# popd >/dev/null || exit 1
EOF
}

gen_body_51e65ac() { cat <<EOF
${func_name}() {
  echo "Function \"${func_name}\" is not implemented yet."
}

if test "\$0" = "\${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  ${func_name} "\$@"
fi
EOF
}

touchbash() {
  test $# = 0 && set -- -
  local path="$1"
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
    file_base="x$unique_id.bash"
  else
    file_base="$path"
    file_base="${file_base##*/}"
    file_base="${file_base##*\\}"
  fi
  local func_name
  func_name="${file_base%.bash}"
  func_name="${func_name//-/_}"
  local has_ext
  case "$file_base" in
    (*.bash)
      has_ext=true
      ;;
    (*)
      has_ext=false
      ;;
  esac
  local is_lib
  case "$file_base" in
    (*.lib.bash|*.libbash|*.bashlib)
      is_lib=true
      echo Generating library Bash script. >&2
      ;;
    (*)
      is_lib=false
      echo Generating Bash script. >&2
      ;;
  esac
  local is_tasks
  # shellcheck disable=SC2034
  case "$file_base" in
    (tasks-*) is_tasks=true;;
    (*) is_tasks=false;;
  esac
  {
    if ! "$is_lib" && ! "$has_ext"
    then
      echo '#!/usr/bin/env bash'
    fi
    gen_header_bf7ac7d
    echo
    if "$is_lib"
    then
      gen_source_block_67741b4
      echo
    else
      gen_source_block_67741b4
      echo
      gen_body_51e65ac
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
    chmod +x "$path"
  fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  touchbash "$@"
fi
