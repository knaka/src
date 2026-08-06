---
name: mise
description: Manage project-local tool versions and tasks with mise. Use when a user asks to run tools, manage tool versions or define project-level tool requirements, or before running any `mise` command.
---

mise manages project-local tool versions and runs tasks. Tool versions are listed in `.mise/config*.toml` and `.config/mise/conf.d/*.toml`.

mise can be invoked without a global installation using the bootstrap scripts: `./mise` on Linux and macOS, or `.\mise.cmd` on Windows.

````bash
# install all tools
./mise install

# execute a locally-installed command
./mise exec -- jq --help

# list available tasks
./mise tasks

# run task `foo`
./mise run foo
````
