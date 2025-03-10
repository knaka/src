#!/bin/sh
test "${guard_920f884+set}" = set && return 0; guard_920f884=-

. ./task.sh

subcmd_bun() { # Run bun(1).
  run_pkg_cmd \
    --cmd=bun \
    --brew-id=oven-sh/bun/bun \
    --winget-id=Oven-sh.Bun \
    --win-cmd-path="$HOME"/AppData/Local/Microsoft/WinGet/Links/bun.exe \
    -- "$@"
}
