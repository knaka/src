#!/bin/sh
test "${guard_fb8b13a+set}" = set && return 0; guard_fb8b13a=-

. ./task.sh
. ./task-node.lib.sh
. ./task-astro.lib.sh
. ./task-bun.lib.sh

. ./task-pages.lib.sh
pages_functions_src_dir_path="./src-pages/functions"

subcmd_test() { # Run tests.
  subcmd_bun test "$@"
}

task_pages__dev() { # Launch the Wrangler Pages development server.
  export NODE_ENV=development
  load_env
  sh task.sh task_pages__functions__watchbuild &
  test "${PAGES_DEV_PORT+set}" = set && set -- "$@" --port "$PAGES_DEV_PORT"
  test "${ASTRO_DEV_PORT+set}" = set && set -- "$@" --binding AP_DEV_PORT="$ASTRO_DEV_PORT"
  subcmd_wrangler pages dev "$@" --live-reload ./dist
}

task_astro__dev() { # Launch the Astro development server.
  export NODE_ENV=development
  load_env
  local host="${ASTRO_DEV_HOST:-127.0.0.1}"
  local port="${ASTRO_DEV_PORT:-3000}"
  set -- "$@" --host "$host"
  set -- "$@" --port "$port"
  if test "${PAGES_DEV_PORT+set}" = set
  then
    export API_DEV_PORT="$PAGES_DEV_PORT"
  fi
  local log_path
  log_path="$(temp_dir_path)"/astro-dev.log
  sh task.sh subcmd_astro dev "$@" </dev/null 2>&1 | tee "$log_path" &
  while true
  do
    sleep 1
    if grep -q "watching for file changes" "$log_path" > /dev/null 2>&1
    then
      break
    fi
  done
  while true
  do
    menu \
      "Open a &browser" \
      "&Clear console" \
      "Bui&ld" \
      "E&xit"
    case "$(get_key)" in
      (b) open_browser "http://$host:$port" ;;
      (c) clear ;;
      (l)
        if task_astro__build
        then
          echo "Built successfully."
        else
          echo "Failed to build."
        fi
        ;;
      (x) break ;;
      (*) ;;
    esac
  done
}

# --------------------------------------------------------------------------
# Database bindings
# --------------------------------------------------------------------------

task_db__gen() { # Generate the database access layer (./sqlcgen/*).
  # Generate the database access layer.
  cross_run ./cmd-gobin run sqlc generate
  # Then, rewrite the generated file.
  file_path=sqlcgen/querier.ts
  temp_path="$(temp_dir_path)"/f695a83
  sed -E \
    -e "s/^([[:blank:]]*[_[:alnum:]]+)(: .* \| null;)$/rewrite_null_def${us}\1${us}\2${us}/" -e t \
    -e "s/^(.*\.${lwb}bind\()([^)]*)(\).*)$/rewrite_bind${us}\1${us}\2${us}\3${us}/" -e t \
    -e "s/^(.*)$/nop${us}\1${us}/" <"$file_path" \
  | while IFS= read -r line
  do
    IFS="$us"
    # shellcheck disable=SC2086
    set -- $line
    unset IFS
    op="$1"
    shift
    case "$op" in
      (rewrite_null_def)
        echo "$1?$2"
        ;;
      (rewrite_bind)
        echo "$1$(echo "$2, " | sed -E -e 's/([^,]+), */typeof \1 === "undefined"? null: \1, /g' -e 's/, $//')$3"
        ;;
      (nop)
        echo "$1"
        ;;
      (*)
        echo Unhandled operation: "$op" >&2
        exit 1
        ;;
    esac
  done >"$temp_path"
  mv "$temp_path" "$file_path"
}
