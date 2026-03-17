#!/usr/bin/env python

data = {
  "name": "Alice",
  "age": 30,
  "hobbies": ["reading", "coding"],
}

# Add some property
data["email"] = "alice@example.com"

# Then pretty print the JSON object to a temp file and open in VSCode
import tempfile
with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=True) as f:
  import json
  json.dump(data, f, indent=2, ensure_ascii=False)
  f.flush()
  import subprocess
  subprocess.run(["code", "--wait", f.name])
