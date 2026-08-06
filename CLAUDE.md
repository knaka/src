# “mise” tool

mise manages project-local tool versions and runs tasks. Tool versions are listed in `.mise/config*.toml` and `.config/mise/conf.d/*.toml` .

## Instructions

mise can be invoked without a global installation using the bootstrap scripts: `./mise` on Linux and macOS, or `.\mise.cmd` on Windows.

```bash
# install all tools
mise install

# list available tasks
mise tasks

# run task `foo`
mise run foo
```

## Task to execute tests

All tests are executed via the `test` task.

````
mise run test
````

To run specific tests, specify their names.

````
mise run test hexdump string_length
````

Tests are implemented following these conventions:

* Placing a `test_foo` function inside a `.lib-test/tests-*.{sh,bash}` script makes the test `foo` available.
* Placing a shell script named `.lib-test/test_bar.{sh,bash}` makes the test `bar` available.
* `.lib/*.{sh,bash}` are scripts that implement functionality, but placing a `test_baz` function inside one makes the test `baz` available.
