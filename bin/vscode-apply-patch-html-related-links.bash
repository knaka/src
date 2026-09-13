#!/usr/bin/env bash
set -- _e97f927 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ./vscode-utils.bash
popd >/dev/null || exit

vscode_apply_patch rioj7.html-related-links . <<'EOF'
--- extension.js.orig	2026-09-13 12:56:39
+++ extension.js	2026-09-13 13:07:18
@@ -173,6 +173,9 @@
         let result;
         while ((result = linkRE.exec(docText)) != null) {
           if (result.length < 2) continue; // no matching group defined
+          if (/^(file|http|https):\/\//.test(result[0])) {
+            result[0] = decodeURIComponent(result[0]);
+          }
           let filePath = result[0].replace(replaceRE, includeObj.filePath);
           filePath = variableSubstitution(filePath, null, document, false);
           if (filePath.length === 0) { continue; }
@@ -595,6 +598,9 @@
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
