BEGIN {
  desc = ""
  mise_hdrs_count = 0
  expecting_task = 0
}
/^#TASK/ {
  expecting_task = 1
  next
}
/^#MISE / || /^# *\[MISE\] / {
  line = $0
  gsub(/^#MISE +/, "", line)
  gsub(/^# *\[MISE\] +/, "", line)
  mise_hdrs[mise_hdrs_count++] = line
  next
}
/^#/ {
  if (desc == "") {
    line = $0
    gsub(/^#+[ ]*/, "", line)
    desc = line
  }
  next
}
/^(task_|task-|subcmd_)[[:alnum:]_-].*\(\)/ || (expecting_task == 1 && /^[[:alnum:]_-].*\(\)/) {
  func_name = $0
  # Cut trailing parentheses.
  sub(/\(\).*$/, "", func_name)
  if (expecting_task) {
    type = "task"
  } else {
    type = func_name
    sub(/[_-].*$/, "", type)
  }
  name = func_name
  if (expecting_task) {
    ;
  } else {
    sub(/^[^_-]+[_-]/, "", name)
  }
  gsub(/__/, ":", name)
  gsub(/--/, ":", name)
  base = FILENAME
  sub(/^.*\//, "", base)
  print type " " name " " func_name " " base " " desc
  for (i = 0; i < mise_hdrs_count; i++) {
    type = "mise"
    print type " " name " " func_name " " base " " mise_hdrs[i]
  }
  desc = ""
  delete mise_hdrs
  mise_hdrs_count = 0
  next
}
{
  desc = ""
  delete mise_hdrs
  mise_hdrs_count = 0
  expecting_task = 0
}
END {
  print "nop - - - -"
}
