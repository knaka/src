import sys
original_wokrking_dir_path = sys.argv[1]
import os
import subprocess
scr_path = os.path.abspath(sys.argv[2])
os.chdir(original_wokrking_dir_path)
process = subprocess.Popen([sys.executable, scr_path] + sys.argv[3:])
process.wait()
sys.exit(process.returncode)
