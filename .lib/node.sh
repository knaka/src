#!/usr/bin/env sh
set -- _ddfed19 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Run `npm install` only if it hasn't been run yet, or if `package.json` has changed since the last run.
npm_install_changed() {
  local rc=1
  local original_pwd="$PWD"
  while :
  do
    if test -r ./package.json
    then
      local last_check_rel_path=./node_modules/.last_install
      if test $# -gt 0 || \
        ! test -d ./node_modules || \
        ! test -r ./package-lock.json ||
        ! test -r "$last_check_rel_path" ||
        test ./package.json -nt "$last_check_rel_path" ||
        test ./package-lock.json -nt "$last_check_rel_path"
      then
        echo "Running npm installation for \"$PWD/package.json\" ." >&2
        if "${MISE_BIN-mise}" exec -- which npm >/dev/null 2>&1
        then
          set -- "${MISE_BIN-mise}" exec -- npm install "$@"
        else
          set -- npm install "$@"
        fi
        if "$@"
        then
          touch "$last_check_rel_path"
          rc=0
        fi
      else
        echo "Skipping npm installation for \"$PWD/package.json\" ." >&2
        rc=0
      fi
      break
    fi
    cd ..
    if test "$PWD" = "$OLDPWD"
    then
      echo "Reached the root directory while searching for a \"package.json\" file." >&2
      break
    fi
  done
  cd "$original_pwd" || exit 1
  return "$rc"
}
