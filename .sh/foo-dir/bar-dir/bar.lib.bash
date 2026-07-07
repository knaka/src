# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
# "${sourced_fbef65e-false}" && return 0; sourced_fbef65e=true
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 2823b44 && return 0

_() {
  local rc=1
  local saved_extdebug
  saved_extdebug=$(shopt -p extdebug || :)
  shopt -s extdebug
  [[ ${BASH_ARGV[0]} != "${BASH_SOURCE[0]}" ]] && rc=0
  eval "$saved_extdebug"
  return "$rc"
}

if _
then
  echo 21848da
else
  echo b27c4c4
fi

# works
# _loaded() { local IFS=" "; [[ "${_ids[*]-}" != *$1* ]] && _ids+=("$1") && return 1 || :; }; _loaded 0f125c4 && return 0

# _loaded() { local IFS=" "; [[ "${_ids[*]-}" != *$1* ]] && _ids+=("$1") && return 1 || :; }; _loaded 0f125c4 && return 0

# _loaded() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1 ${_ids-}"; false;; esac; }; _loaded c97a612 && return 0

# works
# _() {
#   local x="_$1"
#   "${!x-false}" && return 0
#    eval "${x}"=true
#    return 1
# }
# _ 085b560 && return 0

# works
# _v="sourced_c244079"; "${!_v-false}" && return 0; eval "${_v}"=true

# works
# _() {
#   local x="_$1"
#   if ! "${!x-false}"
#   then
#     eval "${x}"=true
#     return 1
#   fi
# }
# _ 085b560 && return 0

## works
## _() {
##   local x="_$1"
##   ! "${!x-false}" && eval "${x}"=true && return 1 || :
## }
## _ 085b560 && return 0

# works
# _(){ local x="_$1"; ! "${!x-false}" && eval "${x}"=true && return 1 || :; }; _ 1a2217b && return 0

# _() {
#   local _v="_c244079"
#   "${!_v-false}" && return 0
#   eval "${_v}"=true
#   false
# }

# _ && return 0

# _s="sourced_87bb09e"; "${!_s-false}" && return 0; eval "${_s}"=true

# id=1bfbef7
# var_name=x"sourced_$id"
# if test "${!var_name+set}" = set
# then
#   return 0
# else
#   declare "${var_name}"=true
# fi

# echo 2fdf0e3 "${_sourced[@]}"

# _sourced+="9d08b89"

# echo 6228828 "${_sourced[@]}"

# # xfbef65e=foobar

# # id=fbef65e
# # var_name=x"$id"
# # echo e786880 "${!var_name}"
# # declare "${var_name}"=xxxyyy

# # echo c722ec5 "$xfbef65e"
# # echo f680b26 "${!var_name}"

echo bar
