#!/usr/bin/env bash
set -- _e97f927 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/version.sh
popd >/dev/null || exit

vscode_apply_patch() {
  local user_exts_dir="$HOME"/.vscode/extensions
  local ext_id="$1"
  local rel_path="$2"
  local ext_dir
  ext_dir="$(
    find "$user_exts_dir" -maxdepth 1 -name "$ext_id-*" \
    | sort_version -r \
    | head -1
  )"
  if test -z "$ext_dir"
  then
    echo c8a3157 >&2
    return 1
  fi
  patch --backup --directory="$ext_dir"/"$rel_path"
}

vscode_apply_patch rioj7.html-related-links . <<'EOF'
--- extension.js.orig	2026-09-13 06:46:31
+++ extension.js	2026-09-13 07:29:45
@@ -595,6 +595,9 @@
       let uri = vscode.Uri.file(link.linkPath);
       if (link.lineSearch) {
         let document = findTextDocument(uri);
+        if (!document) {
+          document = await vscode.workspace.openTextDocument(uri);
+        }
         if (document) {
           [link.lineNr, link.charPos] = searchText(document, link.lineSearch);
         } else {
EOF
