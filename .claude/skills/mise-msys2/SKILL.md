---
name: mise-msys2
description: Know which UNIXy/POSIX commands are available on Windows via the MSYS2 environment mise installs, and which are missing. Use when running shell commands, tests, or tasks on Windows, or troubleshooting a command not found there. Depends on the `mise` skill.
---
# MSYS2 commands in Mise environment on Windows

On Windows, `mise install` installs a base MSYS2 environment (the `http:msys2` tool defined in `.config/mise/conf.d/msys2.toml`) and adds its `msys64/usr/bin` to `PATH`, giving access to standard UNIXy commands (bash, coreutils, sed, grep, awk, perl, tar, curl, ...). This tool is Windows-only; on Linux and macOS these commands come from the system instead.

The `postinstall` step additionally installs `bc`, `diffutils`, and `patch`, so the installed package set is narrower than a full MSYS2 install.

Known-missing commands from the POSIX command set (noticed absent, not currently installed): `ed`, `gcc` (so no `c99`), `m4`, `make`, `vim` (and no `vi`). Don't assume these exist on Windows without checking first.
