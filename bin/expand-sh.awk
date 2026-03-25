#!/usr/bin/awk -f

# Recursively expand dot commands in shell scripts
# Usage: awk -f expand-sh.awk input.sh

function process_line(line,    source_path, prefix) {
  if (line ~ /^\. /) {
    source_path = line
    sub(/^\. */, "", source_path) # Remove ". " prefix
    process_file(source_path)
  } else {
    print line
  }
}

function process_file(filepath,    line) {
  if (filepath in processed) {
    return
  }
  processed[filepath] = 1
  while ((getline line < filepath) > 0) {
    process_line(line)
  }
  close(filepath)
}

{
  process_line($0)
}
