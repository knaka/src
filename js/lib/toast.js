// The CSS is imported as a string, which the build minifies and embeds in the bundle.
import css from "./toast.css";

// Show a message briefly at the bottom of the page, without blocking it as alert() does. The toast is put in a shadow root, so that the styles of the page do not affect it.
export function showToast(message, durationMs = 2000) {
  const host = document.createElement("div");
  const shadow = host.attachShadow({ mode: "open" });
  const style = document.createElement("style");
  style.textContent = css;
  const toast = document.createElement("div");
  toast.className = "toast";
  toast.textContent = message;
  // Let screen readers announce the message.
  toast.setAttribute("role", "status");
  shadow.append(style, toast);
  document.body.appendChild(host);
  // Start the transition in the next frame, after the initial style is applied.
  requestAnimationFrame(() => toast.classList.add("visible"));
  setTimeout(() => {
    toast.classList.remove("visible");
    toast.addEventListener("transitionend", () => host.remove(), { once: true });
  }, durationMs);
}
