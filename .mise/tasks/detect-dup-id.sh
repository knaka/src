#!/usr/bin/env sh
set -- __MISE_TASKS_DETECT_DUP_ID_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

#MISE description="Detect ID duplication among files."

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../../.lib "$OLDPWD" "$@" # shpp:sources
. ../../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

detect_dup_id() {
  cd "$PROJECT_DIR"
  git ls-files \
  | while read -r file
    do
      # echo "$file" >&2
      test -f "$file" || continue
      test -L "$file" && continue
      case "$file" in
        (begin_45a2fb8 \
        |*.json \
        |*.lock \
        |*.yaml \
        |*/*.bak \
        |*/bak.* \
        |*/cmd-gobin \
        |*/go-hello \
        |*/go.mod \
        |*/go.sum \
        |sub/* \
        |end_85190e4)
          continue
          ;;
      esac
      grep -E -o -e '[^0-9a-fA-F][0-9a-fA-F]{7}' \
      <"$file" \
      | sed -e 's/^.//' \
      | tr '[:upper:]' '[:lower:]' \
      | sort \
      | uniq \
      | while read -r line
        do
          # echo "$line" "$file"
          echo "$line"
        done
    done \
  | grep -v \
    -e "474b89b" \
    -e "53c8fd5" \
    -e "0000000" \
    -e "1000000" \
    -e "2024013" \
    -e "2654435" \
    -e "2684354" \
    -e "3681e39" \
    -e "9376eeb" \
    -e "a5f342b" \
    -e "cafebab" \
    -e "cceeded" \
    -e "dfd4bfe" \
    -e "eabed9b" \
    -e "ed9038b" \
    -e "fffffff" \
    -e "bb789ec" \
    -e "e8ccfbb" \
  | sort \
  | uniq -d
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (detect-dup-id.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  detect_dup_id "$@"
fi
