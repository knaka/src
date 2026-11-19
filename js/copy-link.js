import { showToast } from "./lib/toast.js";

async function copyTitle() {
  const title = document.title;
  const url = window.location;
  const link = `[${title}](${url})`;
  await navigator.clipboard.writeText(link);
  return link;
}

// Pass both handlers to then(), rather than chaining catch() after it, so that an error in showing the toast is not reported as a failure to copy.
copyTitle().then(
  (link) => showToast(`Copied: ${link}`),
  (error) => {
    console.error(error);
    alert(`Failed to copy the link: ${error}`);
  },
);
