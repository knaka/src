<!-- +INCLUDE: ./.claude/skills/mise/SKILL.md -->
# “Mise” — tool version and task manager

mise manages project-local tool versions and runs tasks. Tool versions are listed in `.mise/config*.toml` and `.config/mise/conf.d/*.toml`.

mise can be invoked without a global installation using the bootstrap scripts: `./mise` on Linux and macOS, or `.\mise.cmd` on Windows.

````bash
# install all tools
./mise install

# execute a project-locally-installed command
./mise exec -- jq --help

# list available tasks
./mise tasks

# run task `foo`
./mise run foo

# show a task `foo`'s full description and the path of the file that defines it
./mise tasks foo
````
<!-- +END -->

<!-- +INCLUDE: ./.claude/skills/test-task/SKILL.md -->
# Testing

All tests are executed via the `test` task.

````bash-session
$ mise run test
[test] $ # .mise/tasks-test.sh:task_test
Test "octdump"@tests-bindump.sh Passed
Test "hexdump"@tests-bindump.sh Passed
...
````

To run specific tests, specify their names.

````bash-session
$ mise run test hexdump string_length
[test] $ # .mise/tasks-test.sh:task_test
Test "hexdump"@tests-bindump.sh Passed
Test "string_length"@tests-string.sh Passed
````

Tests are implemented following these conventions:

* Placing a `test_foo` function inside a `.lib-test/tests-*.{sh,bash}` script makes the test `foo` available.
* Placing a shell script named `.lib-test/test_bar.{sh,bash}` makes the test `bar` available.
* `.lib/*.{sh,bash}` are scripts that implement functionality, but placing a `test_baz` function inside one makes the test `baz` available.
<!-- +END -->

<!-- +INCLUDE: ./.claude/skills/shell-script-grammar/SKILL.md -->
# Shell Script Grammar

Shell script files with the `.bash` extension must be implemented using only features available up through Bash version 3, since they need to run under Bash version 3 on macOS.

Files with the `.sh` extension should generally be implemented using only POSIX shell features, so that they are executable with Bash POSIX mode, Dash, and BusyBox Ash. However, `local` variable declarations are not part of POSIX shell features, but they can be used as they are available in the shells listed above.

Special shell variables like `$IFS` can be overridden with `local` declarations, which limits their scope to the function and does not affect the outer scope.
<!-- +END -->

<!-- +INCLUDE: ./.claude/skills/mise-msys2/SKILL.md -->
# MSYS2 commands in Mise environment on Windows

On Windows, `mise install` installs a base MSYS2 environment (the `http:msys2` tool defined in `.config/mise/conf.d/msys2.toml`) and adds its `msys64/usr/bin` to `PATH`, giving access to standard UNIXy commands (bash, coreutils, sed, grep, awk, perl, tar, curl, ...). This tool is Windows-only; on Linux and macOS these commands come from the system instead.

The `postinstall` step additionally installs `bc`, `diffutils`, and `patch`, so the installed package set is narrower than a full MSYS2 install.

Known-missing commands from the POSIX command set (noticed absent, not currently installed): `ed`, `gcc` (so no `c99`), `m4`, `make`, `vim` (and no `vi`). Don't assume these exist on Windows without checking first.
<!-- +END -->
