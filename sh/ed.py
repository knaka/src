#!/usr/bin/env python3
# vim: set filetype=python tabstop=2 shiftwidth=2 expandtab :

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

import argparse

HOME = Path.home()

# Color palette
bred    = "#efafaf"
bgreen  = "#afefaf"
bblue   = "#afafef"
byellow = "#efefaf"
bmagenta= "#efafef"
bcyan   = "#afefef"

def color_midpoint(c1: str, c2: str) -> str:
  """Return the midpoint color between two hex colors (#rrggbb)."""
  x1 = int(c1.lstrip("#"), 16)
  x2 = int(c2.lstrip("#"), 16)
  r = ((x1 >> 16 & 0xff) + (x2 >> 16 & 0xff)) // 2
  g = ((x1 >>  8 & 0xff) + (x2 >>  8 & 0xff)) // 2
  b = ((x1       & 0xff) + (x2       & 0xff)) // 2
  return f"#{r:02x}{g:02x}{b:02x}"

def get_editor_cmd(block: bool) -> list[str]:
  """Return the editor command to use."""
  if shutil.which("code"):
    cmd = ["code"]
    if block:
      cmd.append("--wait")
    return cmd
  editor = os.environ.get("EDITOR", "vi")
  return [editor]

def prompt_confirm(message: str, default: str = "n") -> bool:
  """Show a yes/no prompt and return the user's choice (single keypress)."""
  import tty
  import termios
  default = default.lower()
  choices = "Y/n" if default == "y" else "y/N"
  print(f"{message} [{choices}]: ", end="", flush=True, file=sys.stderr)
  fd = sys.stdin.fileno()
  old = termios.tcgetattr(fd)
  try:
    tty.setraw(fd)
    ch = sys.stdin.read(1).lower()
  finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, old)
  response = ch if ch.strip() else default
  print(response, file=sys.stderr)
  return response in ("y", "yes")

def make_workspace(arg: Path) -> Path | None:
  """Create a .code-workspace file for the directory and return its path."""
  color = subcolor = None

  src_root = HOME / "repos" / "github.com" / "knaka" / "src"

  # (prefix_or_exact_path, color, subcolor_or_None)
  rules: list[tuple[Path, str, str | None]] = [
    (src_root / "sh", bblue, bred),
    (src_root / "go", bblue, byellow),
    (src_root,        bblue, None),
    (HOME / "MyDrive" / "doc", byellow, None),
  ]

  for prefix, c, sc in rules:
    if arg == prefix or str(arg).startswith(str(prefix) + "/"):
      color = c
      subcolor = sc
      break

  if color is None:
    return None

  if subcolor:
    midcolor = color_midpoint(color, subcolor)
  else:
    subcolor = color
    midcolor = color

  cache_dir = HOME / ".cache" / "code-workspaces"
  cache_dir.mkdir(parents=True, exist_ok=True)
  workspace_file = cache_dir / f"{arg.name}.code-workspace"

  workspace = {
    "folders": [{"path": str(arg)}],
    "settings": {
      "workbench.colorCustomizations": {
        "titleBar.activeBackground": color,
        "titleBar.inactiveBackground": color,
        "statusBar.background": subcolor,
        "activityBar.background": midcolor,
      }
    },
  }
  workspace_file.write_text(json.dumps(workspace))
  return workspace_file

def launch_editor(paths: list[Path], block: bool) -> None:
  cmd = get_editor_cmd(block)
  subprocess.run(cmd + [str(p) for p in paths])

def edit(
  paths: list[str],
  block: bool = False,
  dereference: bool = False,
  raw: bool = False,
) -> None:
  to_open: list[Path] = []

  for arg_str in paths:
    arg = Path(arg_str)

    if arg.exists():
      if arg.is_dir():
        # Directory
        print(f"{arg} is a directory. ", end="", file=sys.stderr)
        if not prompt_confirm("Open?", "n"):
          sys.exit(0)
        real = arg.resolve()
        ws = make_workspace(real)
        to_open.append(ws if ws is not None else real)

      elif arg.is_file():
        # Resolve the parent dir only (keep filename as-is for symlinks)
        resolved = arg.parent.resolve() / arg.name
        if dereference:
          resolved = resolved.resolve()
        if raw:
          # edr: open a temporary copy and sync back — replicate simply as direct open
          to_open.append(resolved)
        else:
          to_open.append(resolved)
      else:
        sys.exit(1)
    else:
      # Not existing — resolve parent dir
      resolved = arg.parent.resolve() / arg.name
      if dereference:
        resolved = resolved.resolve()
      if not resolved.exists():
        print(f"File {resolved} does not exist. ", end="", file=sys.stderr)
        if not prompt_confirm("Create?", "n"):
          sys.exit(0)
        resolved.parent.mkdir(parents=True, exist_ok=True)
        resolved.touch()
      to_open.append(resolved)

  if to_open:
    launch_editor(to_open, block)

def main() -> None:
  parser = argparse.ArgumentParser(prog="ed", add_help=False)
  parser.add_argument("--block", "--wait", "-b", "-w", action="store_true")
  parser.add_argument("--dereference", "-L", action="store_true")
  parser.add_argument("--raw", "-r", action="store_true")
  parser.add_argument("paths", nargs="*")
  ns = parser.parse_args()
  edit(**vars(ns))

if __name__ == "__main__":
  main()
