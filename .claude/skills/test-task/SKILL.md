---
name: test-task
description: Run this project's tests via the mise `test` task, and understand the conventions used to define tests. Use when asked to run, add, or locate a test. Depends on the `mise` skill.
---
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
