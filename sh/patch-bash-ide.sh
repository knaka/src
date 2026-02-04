#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a92e981-false}" && return 0; sourced_a92e981=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
cd "$1"; shift 2

patch_bash_ide() {
  local user_exts_dir="$HOME/.vscode/extensions"
  local bash_ide_ext_dir
  local bash_ide_ext_dir="$(
    find "$user_exts_dir" -maxdepth 1 -name "mads-hartmann.bash-ide-vscode-*" \
    | sort_version -r \
    | head -1
  )"
  if test -z "$bash_ide_ext_dir"
  then
    echo 4a443e5 >&2
    exit 1
  fi
  patch --backup --directory "$bash_ide_ext_dir"/node_modules/bash-language-server/out/util "$@" <<'EOF'
--- sourcing.js.orig
+++ sourcing.js
@@ -2,6 +2,7 @@
 Object.defineProperty(exports, "__esModule", { value: true });
 exports.getSourceCommands = void 0;
 const fs = require("fs");
+const url = require("url");
 const path = require("path");
 const directive_1 = require("../shellcheck/directive");
 const discriminate_1 = require("./discriminate");
@@ -110,10 +111,10 @@
     }
     // resolve  relative path
     for (const rootPath of rootPaths) {
-        const potentialPath = path.join(rootPath.replace('file://', ''), sourcedPath);
+        const potentialPath = path.join(url.fileURLToPath(rootPath), sourcedPath);
         // check if path is a file
         if (fs.existsSync(potentialPath)) {
-            return `file://${potentialPath}`;
+            return url.pathToFileURL(potentialPath).href;
         }
     }
     return null;
EOF
}

case "${0##*/}" in
  (patch-bash-ide.sh|patch-bash-ide)
    set -o nounset -o errexit
    patch_bash_ide "$@"
    ;;
esac
