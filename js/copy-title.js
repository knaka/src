async function copyTitle() {
  await navigator.clipboard.writeText(document.title);
}

copyTitle().catch((error) => {
  console.error(error);
  alert(`Failed to copy the title: ${error}`);
});
