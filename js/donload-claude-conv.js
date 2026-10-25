// Downloads the data of a Claude chat conversation. Intended to be run in the
// browser on a claude.ai chat page, either as a bookmarklet or as a custom
// shortcut via a tool such as Shortkeys.

function fail(message) {
  alert(message);
  throw new Error(message);
}

// Fetches the conversation from claude.ai's internal API (the same endpoint the
// web app itself uses) and returns it as parsed JSON.
async function fetchConv(orgId, convId) {
  const url = `/api/organizations/${orgId}/chat_conversations/${convId}?tree=true&rendering_mode=messages&render_all_tools=true`;
  let response;
  try {
    response = await fetch(url, {
      credentials: 'include',
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    fail(`Error 483dbf3: ${error.message}`);
  }
  if (!response.ok) {
    fail(`Error 2fb0b1a: ${response.status}`);
  }
  try {
    return await response.json();
  } catch (error) {
    fail(`Error 73a13ec: ${error.message}`);
  }
}

// Saves `content` to the user's machine as `filename` by clicking a temporary
// link to an in-memory blob. `type` is the MIME type.
async function download(filename, content, type = 'application/json;charset=utf-8') {
  const blob = new Blob([content], { type });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

async function downloadClaudeConv() {
  const orgId = document.cookie.match(/lastActiveOrg=([^;]+)/)?.[1];
  if (!orgId) {
    fail("Couldn't read lastActiveOrg cookie");
  }
  const convId = window.location.pathname.split('/').pop();
  download(
    `claude-conv-${convId}.json`,
    JSON.stringify(await fetchConv(orgId, convId)),
  );
}

downloadClaudeConv();
