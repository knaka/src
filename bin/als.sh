# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*);; (*) _ids="$1,${_ids-}"; false;; esac; }; _ ef9014f && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR .lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift

als() {
  local file
  for file in "$@"
  do
    case "$file" in
      (ftp:*|http:*|https:*)
        init_temp
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

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ als
then
  set -o nounset -o errexit
  als "$@"
fi
