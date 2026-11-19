// Bundle each script at the top level with the modules it imports into dist/, minified and wrapped in an IIFE, so that it can be run as a bookmarklet or pasted into the browser console.
import * as esbuild from "esbuild";
import { readFile } from "node:fs/promises";
import { writeFileSync } from "node:fs";

// Import a CSS file as a minified string. The "text" loader of esbuild alone embeds the CSS as is, without minifying it.
const minifiedCssText = {
  name: "minified-css-text",
  setup(build) {
    build.onLoad({ filter: /\.css$/ }, async (args) => {
      const source = await readFile(args.path, "utf8");
      const { code } = await esbuild.transform(source, { loader: "css", minify: true });
      return { contents: code.trim(), loader: "text" };
    });
  },
};

const result = await esbuild.build({
  entryPoints: ["./*.js", "./*.ts"],
  bundle: true,
  minify: true,
  format: "iife",
  outdir: "dist",
  plugins: [minifiedCssText],
  logLevel: "info",
  write: false,
});

for (const out of result.outputFiles) {
  writeFileSync(out.path, out.text.replace(/\r?\n$/, ''));
}
