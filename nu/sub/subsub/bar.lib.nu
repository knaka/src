if ($env.PROCESS_PATH | path expand) == $env.CURRENT_FILE {
  print "Bar Executed."
} else {
  print "Bar Sourced."
}
