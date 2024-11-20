#!/bin/sh
# shellcheck disable=SC3043
test "${guard_e249abe+set}" = set && return 0; guard_e249abe=x
set -o nounset -o errexit

. ./task.sh
. ./task-volta.lib.sh
. ./task-next.lib.sh
. ./task-sqlite3.lib.sh

mkdir_sync_ignored .wrangler build
mkdir_sync_ignored .gobin

mkdir -p .wrangler
set_sync_ignored .wrangler

# --------------------------------------------------------------------------
# Commands.
# --------------------------------------------------------------------------

subcmd_wrangler() { # Run the Cloudflare Wrangler command.
  set_node_env
  node"$(exe_ext)" node_modules/wrangler/bin/wrangler.js "$@"
}

subcmd_esbuild() { # Run the esbuild, the JavaScript bundler command.ss
  set_node_env
  local cmd_path="$SCRIPT_DIR/node_modules/esbuild/bin/esbuild"
  if head -1 "$cmd_path" | grep -q node
  then
    node "$cmd_path" "$@"
    return $?
  fi
  "$cmd_path" "$@"
}

# --------------------------------------------------------------------------
# Cloudflare Workers codes.
# --------------------------------------------------------------------------

# shellcheck disable=SC2120
task_worker__build() { # Build the worker files into a JS file.
  subcmd_esbuild "$@" --bundle worker/index.ts --format=esm --outfile=public/_worker.js
}

task_worker__depbuild() { # Build the worker files if the source files are newer than the output files.
  if newer worker/ --than public/_worker.js
  then
    task_worker__build
  fi
}

# --------------------------------------------------------------------------
# Next.js codes.
# --------------------------------------------------------------------------

task_next__build() { # Build the Next.js project.
  subcmd_next build "$@"
}

# shellcheck disable=SC2120
task_next__depbuild() { # Build the Next.js project if the source files are newer than the output files.
  # Output dir is specified in ./next.config.js.
  if newer app/ public/ --than build/out
  then
    task_next__build "$@"
  fi
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

# --------------------------------------------------------------------------
# Development Local D1 Database
# --------------------------------------------------------------------------

subcmd_local_d1__exec() { # Execute SQL command in the development D1 database.
  subcmd_wrangler d1 execute --local test-db "$@"
}

task_local_d1__schema() { # Export the schema of the development D1 database.
  mkdir -p build/
  subcmd_wrangler d1 export --local --no-data --output=build/dev-schema.sql test-db
}

task_local_d1__dump() { # Dump the development database.
  subcmd_wrangler d1 export --local --output=/dev/stdout test-db
}

task_local_d1__drop() { # Drop the development database.
  find .wrangler -type f -name "*.sqlite*" -print0 | xargs -0 -n1 rm -f
}

task_local_d1__create() { # Create the development database.
  subcmd_local_d1__exec --command "SELECT current_timestamp"
}

task_local_d1__diff() { # Generate the schema difference between the development database and the schema file.
  task_local_d1__schema
  rm -f build/dev-schema.db
  subcmd_sqlite3 build/dev-schema.db < build/dev-schema.sql
  cross_run ./cmd-gobin run sqlite3def --file=schema.sql build/dev-schema.db --dry-run > build/dev-diff.sql
  cat build/dev-diff.sql
}

task_local_d1__migrate() { # Apply the schema changes to the development database.
  task_local_d1__diff
  if test "$(sha1sum build/dev-diff.sql | field 1)" = e7efbf38cff7d12493cbe795586c588dccb332f4
  then
    echo "No schema changes."
    return 0
  fi
  subcmd_local_d1__exec --file=build/dev-diff.sql
}

# --------------------------------------------------------------------------
# Preview
# --------------------------------------------------------------------------

task_pages__start() { # Launch the Wrangler Pages local server.
  subcmd_wrangler pages dev build/out/
}

task_start() { # Launch the Pages preview server.
  NODE_ENV=production
  export NODE_ENV
  APP_ENV=production
  export APP_ENV
  sh task.sh task_worker__build
  # "EBUSY" error occurs on Windows frequently.
  if is_windows
  then
    for _ in 1 2 3
    do
      rm -fr .next/* > /dev/null 2>&1 || :
      sleep 1
    done
    rm -fr .next/*
  fi
  sh task.sh task_next__build
  # Wrangler provides interactive CUI.
  sh task.sh task_pages__start
}

# --------------------------------------------------------------------------
# Development
# --------------------------------------------------------------------------

task_worker__watchbuild() { # Watch the worker files and build them into JS files.
  # "forever" to keep the process running even after the stdin is closed.
  subcmd_esbuild "$@" --bundle worker/index.ts --format=esm --outfile=public/_worker.js --watch=forever
}

task_db__watchgen() { # Watch the SQL files and generate the database access layer (./sqlcgen/*).
  while true
  do
    if newer query.sql schema.sql --than sqlcgen/
    then
      sh task.sh task_db__gen
    fi
    sleep 10    
  done
}

task_worker__dev() { # Launch the Worker service in the development mode.
  load_env
  if test "${NEXT_PUBLIC_API_PORT+set}" = set
  then
    set -- "$@" --port "$NEXT_PUBLIC_API_PORT"
  fi
  subcmd_wrangler pages dev "$@" --live-reload --show-interactive-dev-session=false public/
}

usage_next_prompt() {
  echo
  echo "[b] Open a Browser"
  echo "[c] Clear console"
  echo "[x] to exit"
}

next_prompt() {
  usage_next_prompt
  while true
  do
    case "$(get_key)" in
      b) open_browser "$1" ;;
      c) clear ;;
      x) break ;;
      *) usage_next_prompt ;;
    esac
  done
}

task_next__dev() { # Launch the Next.js development server.
  load_env
  opts_93039d0=
  if test "${NEXT_DEV_SERVER_PORT+set}" = set
  then
    opts_93039d0="--port=$NEXT_DEV_SERVER_PORT"
  fi
  set_node_env
  # shellcheck disable=SC2086
  subcmd_next dev $opts_93039d0
}

task_dev() { # Launch the development servers.
  NODE_ENV=development
  export NODE_ENV
  APP_ENV=development
  export APP_ENV
  sh task.sh task_worker__watchbuild &
  sh task.sh task_worker__dev &
  sh task.sh task_next__dev 2>&1 | tee "$(temp_dir_path)"/next-dev.log &
  while true
  do
    sleep 1
    if grep -q "Ready in " "$(temp_dir_path)"/next-dev.log > /dev/null 2>&1
    then
      break
    fi
  done
  load_env
  next_prompt "http://localhost:${NEXT_DEV_SERVER_PORT:-3000}"
}
