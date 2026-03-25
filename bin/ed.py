#!/usr/bin/env python3
# vim: set filetype=python tabstop=2 shiftwidth=2 expandtab :

from typing import Final
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
from pathlib import Path
import argparse

HOME: Final = Path.home()

# Bright colors
BRED: Final     = "#efafaf"
BGREEN: Final   = "#afefaf"
BBLUE: Final    = "#afafef"
BYELLOW: Final  = "#efefaf"
BMAGENTA: Final = "#efafef"
BCYAN: Final    = "#afefef"

BCOLORS: Final = [BRED, BGREEN, BBLUE, BYELLOW, BMAGENTA, BCYAN,]

# And dark colors
DRED: Final     = "#901010"
DGREEN: Final   = "#109010"
DBLUE: Final    = "#101090"
DYELLOW: Final  = "#909010"
DMAGENTA: Final = "#109090"
DCYAN: Final    = "#901090"

DCOLORS: Final = [DRED, DGREEN, DBLUE, DYELLOW, DMAGENTA, DCYAN,]

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
    (src_root / "bin", BBLUE, BRED),
    (src_root / "go",  BBLUE, BGREEN),
    (src_root,         BBLUE, None),
    (HOME / "MyDrive" / "doc", BYELLOW, None),
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
  fgcolor = "#000000"
  inactive_fgcolor = "#7f7f7f"
  if color in BCOLORS:
    fgcolor = "#000000"
    inactive_fgcolor = "#7f7f7f"
  elif color in DCOLORS:
    fgcolor = "#ffffff"
    inactive_fgcolor = "#cfcfcf"

  cache_dir = HOME / ".cache" / "code-workspaces"
  cache_dir.mkdir(parents=True, exist_ok=True)
  workspace_file = cache_dir / f"{arg.name}.code-workspace"

  workspace = {
    "folders": [{"path": str(arg)}],
    "settings": {
      "workbench.colorCustomizations": {
        "titleBar.activeBackground": color,
        "titleBar.activeForeground": fgcolor,
        "titleBar.inactiveBackground": color,
        "titleBar.inactiveForeground": fgcolor,

        "activityBar.background": midcolor,
        "activityBar.foreground": fgcolor,
        "activityBar.inactiveForeground": inactive_fgcolor,
  
        "statusBar.background": subcolor,
        "statusBar.foreground": fgcolor,
      }
    },
  }
  workspace_file.write_text(json.dumps(workspace))
  return workspace_file

def launch_editor(paths: list[Path], block: bool) -> None:
  cmd = get_editor_cmd(block)
  subprocess.run(cmd + [str(p) for p in paths])

def _sync_if_newer(src: Path, dst: Path) -> None:
  """Copy src to dst if src is newer than dst."""
  if src.stat().st_mtime > dst.stat().st_mtime:
    shutil.copy2(src, dst)

def edit(
  paths: list[str],
  block: bool = False,
  dereference: bool = False,
  raw: bool = False,
) -> None:
  """Open files in an editor.

  block:       Wait for the editor to close before returning.
  dereference: Resolve symlinks fully before opening.
  raw:         Open a temporary copy with a random name (no extension) so that
               the editor does not associate it with any language mode,
               suppressing formatters and linters tied to the original
               filename/extension. Changes are synced back to the original
               file periodically and on exit.
  """
  to_open: list[Path] = []
  # pairs of (tmp_copy, original) for raw mode
  raw_pairs: list[tuple[Path, Path]] = []
  tmp_dir: str | None = None
  stop_event = threading.Event()

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
          if tmp_dir is None:
            tmp_dir = tempfile.mkdtemp(prefix="edr_")
          fd, tmp_str = tempfile.mkstemp(dir=tmp_dir)
          os.close(fd)
          tmp = Path(tmp_str)
          shutil.copy2(resolved, tmp)
          raw_pairs.append((tmp, resolved))
          to_open.append(tmp)
          block = True
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

  if raw_pairs:
    def sync_loop() -> None:
      while True:
        if stop_event.wait(5):
          break
        for tmp, origin in raw_pairs:
          _sync_if_newer(src=tmp, dst=origin)
    t = threading.Thread(target=sync_loop, daemon=True)
    t.start()

  try:
    if to_open:
      launch_editor(to_open, block)
  finally:
    if raw_pairs:
      stop_event.set()
      for tmp, origin in raw_pairs:
        _sync_if_newer(src=tmp, dst=origin)
    if tmp_dir:
      shutil.rmtree(tmp_dir, ignore_errors=True)

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
