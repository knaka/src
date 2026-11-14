async function copyTitle() {
  const title = document.title;
  const url = window.location;
  const link = `[${title}](${url})`;
  await navigator.clipboard.writeText(link);
}

copyTitle().catch((error) => {
  console.error(error);
  alert(`Failed to copy the link: ${error}`);
});
