BEGIN {
  desc = ""
  mise_hdrs_count = 0
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
/^(task_|task-|subcmd_)[[:alnum:]_-]()/ {
  func_name = $1
  # Cut trailing parentheses.
  sub(/\(\).*$/, "", func_name)
  type = func_name
  sub(/[_-].*$/, "", type)
  name = func_name
  sub(/^[^_-]+[_-]/, "", name)
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
}
END {
  print "nop - - - -"
}
