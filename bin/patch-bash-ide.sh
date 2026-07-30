#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_PATCH_BASH_IDE_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

patch_bash_ide() {
  local user_exts_dir="$HOME/.vscode/extensions"
  local bash_ide_ext_dir
  bash_ide_ext_dir="$(
    find "$user_exts_dir" -maxdepth 1 -name "mads-hartmann.bash-ide-vscode-*" \
    | sort_version -r \
    | head -1
  )"
  if test -z "$bash_ide_ext_dir"
  then
    echo 4a443e5 >&2
    exit 1
  fi
  # BusyBox patch(1) lacks the featuress
  # patch --backup --directory "$bash_ide_ext_dir"/node_modules/bash-language-server/out/util "$@" <<'EOF'
  push_dir "$bash_ide_ext_dir"/node_modules/bash-language-server/out/util
  cp -f sourcing.js sourcing.js.orig
  patch "$@" <<'EOF'
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
  pop_dir
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (patch-bash-ide.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  patch_bash_ide "$@"
fi
