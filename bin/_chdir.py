import os
import runpy
import sys

def main() -> None:
  os.chdir(sys.argv[1])
  script = sys.argv[2]
  sys.argv = sys.argv[2:]
  runpy.run_path(script, run_name="__main__")

if __name__ == "__main__":
  main()
