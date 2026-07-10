function reset_vars() {
  re_delim = ""
  file = ""
}

BEGIN {
  reset_vars()
}

(/^#EMBED: */) {
  _ = $0
  sub(/^#EMBED: */, "", _)
  file = _
}

(re_delim) {
  if ($0 ~ re_delim) {
    if (file) {
      while ((getline line < file) > 0) {
        print line
      }
    }
    reset_vars()
  } else {
    next
  }
}

((! red_delim) && /^.*<< *['"]?[a-zA-Z_][a-zA-Z_]*['"]?/) {
  _ = $0
  sub(/^.*<< *['"]?/, "", _) # '"
  match(_, /[a-zA-Z_][a-zA-Z_]*/)
  re_delim = "^" substr(_, RSTART, RLENGTH)
}

{
  print
}
