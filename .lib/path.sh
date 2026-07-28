#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ _LIB_PATH_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@" # shpp:begin_source
. ./utils.sh
cd "$3" || exit; shift 3 # shpp:end_source

# [<target> [source=$PWD]] Convert absolute path to relative path
abs2rel() {
  local target="$1"
  shift
  local source="$PWD"
  if test "$#" -gt 0
  then
    source="$1"
  fi
  # if is_msys2
  # then
  #   realpath "$target" --relative-to "$source"
  #   return $?
  # fi
  local drive=
  if is_windows
  then
    case "$target" in
      (*:*)
        drive="${target%%:*}:"
        target="${target#*:}"
        ;;
    esac
  fi
  if is_windows
  then
    local source_drive
    source_drive="${source%%:*}:"
    if test -n "$drive" && ! test "$source_drive" = "$drive"
    then
      echo "$drive$target"
      return 0
    fi
    source="${source#*:}"
  fi

  # Same path
  if test "$target" = "$source"
  then
    echo "${drive}."
    return 0
  fi

  # Ensure paths don't have trailing slashes (except root)
  target="${target%/}"
  source="${source%/}"
  test -z "$target" && target="/"
  test -z "$source" && source="/"

  local common="$source"
  local back=

  # Find common ancestor
  while :
  do
    # Check if target equals common
    if test "$target" = "$common"
    then
      break
    fi
    # Check if target starts with common/ (or common is root)
    if test "$common" = "/"
    then
      # Root is always a prefix of any absolute path
      break
    fi
    case "$target" in
      ("$common"/*)
        break
        ;;
    esac
    # Go up one directory
    local parent
    parent=$(dirname "$common")
    if test "$parent" = "$common"
    then
      # Reached root
      common="/"
      back="../${back}"
      break
    fi
    common="$parent"
    back="../${back}"
  done

  # Build the relative path
  if test "$target" = "$common"
  then
    # Target is an ancestor of source
    if test -z "$back"
    then
      echo "${drive}."
    else
      echo "${drive}${back%/}"
    fi
  else
    # Remove common prefix from target
    local suffix
    if test "$common" = "/"
    then
      suffix="${target#/}"
    else
      suffix="${target#"$common"/}"
    fi
    echo "${drive}${back}${suffix}"
  fi
}
