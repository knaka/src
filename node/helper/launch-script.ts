import { spawn } from 'child_process';

const working_dir = process.argv[2];
const args = process.argv.slice(3);

spawn(
  process.execPath,
  args,
  {
    stdio: 'inherit',
    cwd: working_dir
  }
)
.on('close',
  (code) => process.exit(code ?? 0)
)
.on('error',
  (err) => {
    console.error(err);
    process.exit(1);
  }
);
