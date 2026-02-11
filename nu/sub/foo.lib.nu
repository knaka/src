source ./subsub/bar.lib.nu

export def foo [] {
  echo "Foo"
}

# Special Variables | Nushell https://www.nushell.sh/book/special_variables.html
if $env.CURRENT_FILE == ($env.PROCESS_PATH | path expand) {
  foo
}
