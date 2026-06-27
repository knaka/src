function reset_vars() {
  desc = ""
  delete mise_hdrs
  mise_hdrs_count = 0
  is_task = 0
  task_name = ""
}

BEGIN {
  reset_vars()
}

/^#TASK($| +)/ {
  is_task = 1
  if (/^.* name=/) {
    _ = $0
    sub(/^.* name=/, "", _)
    sub(/ +.*$/, "", _)
    task_name = _
  }
  if (/^.* desc=/) {
    _ = $0
    sub(/^.* desc="/, "", _)
    sub(/".*$/, "", _)
    desc = _
  }
  next
}

/^#MISE / || /^# *\[MISE\] / {
  _ = $0
  gsub(/^#MISE +/, "", _)
  gsub(/^# *\[MISE\] +/, "", _)
  mise_hdrs[mise_hdrs_count++] = _
  next
}

/^#/ {
  if (desc == "") {
    _ = $0
    gsub(/^#+[ ]*/, "", _)
    desc = _
  }
  next
}

(is_task && /^[[:alnum:]_-].*\(\)/) || /^(task_|task-|subcmd_)[[:alnum:]_-].*\(\)/ {
  _ = $0
  sub(/\(\).*$/, "", _)
  func_name = _
  if (is_task) {
    type = "task"
    if (! task_name) {
      _ = func_name
      gsub(/(__|--)/, ":", _)
      task_name = _
    }
  } else {
    _ = func_name
    sub(/[_-].*$/, "", _)
    type = _
    _ = func_name
    sub(/^[^_-]+[_-]/, "", _)
    gsub(/(__|--)/, ":", _)
    task_name = _
  }
  _ = FILENAME
  sub(/^.*\//, "", _)
  base = _
  print type " " task_name " " func_name " " base " " desc
  for (i = 0; i < mise_hdrs_count; i++) {
    type = "mise"
    print type " " task_name " " func_name " " base " " mise_hdrs[i]
  }
  reset_vars()
  next
}

{
  reset_vars()
}

END {
  print "nop - - - -"
}
