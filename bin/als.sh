#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_ALS_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

als() {
  local file
  for file in "$@"
  do
    case "$file" in
      (ftp:*|http:*|https:*)
        init_temp_dir
        local temp_file
        temp_file="$TEMP_DIR"/"$(basename "$file")"
        curl "$file" --output "$temp_file" >&2
        file="$temp_file"
    esac
    case "$file" in
      (*.a) ar tv "$file";;
      (*.tgz|*.tar.gz) tar ztvf "$file";;
      (*.cgz|*.cpio.gz) gzip -d -c "$file" | cpio --list --verbose;;
      (*.cpio) cpio --list --verbose < "$file";;
      (*.tbz|tar.bz2) tar -t -v -f "$file" --bzip2;;
      (*.zip|*.ZIP|*.jar|*.xpi|*.egg|*.war|*.ipa|*.xlsx) unzip -l "$file";;
      (*.tar.lzma) tar Ytvf "$file";;
      (*.tar.Z) tar Ztvf "$file";;
      (*.tar|*.gem) tar tvf "$file";;
      (*.rpm) rpm2cpio "$file" | cpio --unconditional --list -v;;
      (*.lzh|*.Lzh|*.LZH) lha l "%s";;
      (*.msi|*.7z) 7z l "$file";;
      (*.rar) unrar l "$file";;
      (*.txz|*.tar.xz) tar Jtvf "$file";;
      (*.phar) phar "$file";;
      (*)
        echo Not supported: "$file"
        return 1
        ;;
    esac
  done
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.als.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  als "$@"
fi
