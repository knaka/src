// A CSS file is imported as a string, which build.mjs minifies and embeds in the bundle.
declare module "*.css" {
  const css: string;
  export default css;
}
