#!/usr/bin/env bash
set -- __MISE_TASKS_LIB_NODE_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/build.sh
popd >/dev/null || exit

# Install npm packages if "package.json" has been updated.
task_npm__install() {
  local retcmds="trap - RETURN"
  trap 'eval "$retcmds"' RETURN
  pushd . >/dev/null
  retcmds="popd >/dev/null || exit; $retcmds"
  cd "${INIT_CWD-}" || :
  cd "${MISE_ORIGINAL_CWD-}" || :
  cd "${INITIAL_DIR-}" || :
  while :
  do
    test -r ./package.json && break
    cd ..
    if test "$PWD" = "$OLDPWD"
    then
      echo "Reached the root directory while searching for a \"package.json\" file." >&2
      return 1
    fi
  done
  local last_check_rel_path=./node_modules/.npm_last_check
  while :
  do
    test $# -gt 0 && break
    ! test -d ./node_modules && break
    ! test -r ./package-lock.json && break
    ! test -r "$last_check_rel_path" && break
    updated ./package.json --after "$last_check_rel_path" && break
    updated ./package-lock.json --after "$last_check_rel_path" && break
    return 0
  done
  npm install "$@"
  touch "$last_check_rel_path"
}
