import { createServer } from 'http';
import { promises as fs } from 'node:fs';
import { extname, join } from 'path';
import { createReadStream } from 'node:fs';
import { lookup } from 'mime-types';

const host = process.argv[2] || '127.0.0.1';
const port = process.argv[3] || 80;
const working_dir = process.argv[4] || process.cwd();

async function tryStatAsync(path) {
  try {
    return await fs.stat(path);
  } catch {
    return null;
  }
}

const server = createServer(async (reqIn, respOut) => {
  let filePath = join(working_dir, reqIn.url === '/' ? 'index.html' : reqIn.url);
  if ((await tryStatAsync(filePath))?.isFile()) {
    // do nothing
  } else if ((await tryStatAsync(filePath + '.html'))?.isFile()) {
    filePath += '.html';
  } else if ((await tryStatAsync(filePath + '/index.html'))?.isFile()) {
    filePath += '/index.html';
  } else {
    respOut.writeHead(404, { 'Content-Type': 'text/plain' });
    respOut.end('404 Not Found');
    console.log(`404 Not Found: ${filePath}`);
    return;
  }
  const ext = extname(filePath);
  const mimeType = lookup(ext) || 'application/octet-stream';
  respOut.writeHead(200, { 'Content-Type': mimeType });
  createReadStream(filePath).pipe(respOut);
});

server.listen(port, host, () => {
  console.log(`HTTP Server running at http://${host}:${port}/ , providing the content of the current directory (${working_dir})`);
});
