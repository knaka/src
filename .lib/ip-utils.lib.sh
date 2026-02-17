# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_a642529-}" = true && return 0; sourced_a642529=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR . "$@"
. ./utils.lib.sh
shift 2
cd "$1" || exit 1; shift

# List IP ports in use.
ip_ports_in_use() {
  if is_windows
  then
    # -a: Displays all connections and listening ports.
    # -n: Displays addresses and port numbers in numerical form.
    # -p protocol: Shows connections for the protocol specified by protocol.
    netstat.exe -a -n -p TCP | grep TCP | awk '{ print $2 }' | sed -n -e 's/^.*://p' | sort -n | uniq
  elif is_macos
  then
    # -a: Show the state of all sockets.
    # -n: Show numerical addresses instead of trying to determine symbolic host, port or user names.
    # -v: Verbose.
    # -s protocol: Display statistics for the specified protocol.
    netstat -anvp tcp | grep ^tcp4 | awk '{ print $4 }' | sed 's/.*\.//'
  elif is_linux
  then
    if ! command -v ss >/dev/null
    then
      if is_debian
      then
        echo "ss(8) not found. Please install iproute2 package." >&2
        exit 1
      fi
      echo "ss(8) not found." >&2
      exit 1
    fi
    # --tcp: Display TCP sockets.
    # --all: Display all sockets. (Not only listening sockets (-n), but also established connections.)
    # --numeric: Do not resolve service names.
    ss --tcp --all --numeric --no-header | awk '{ print $4 }' | sed -n -e 's/^.*://p'
  else
    echo "Not implemented (490a9b1)" >&2
    exit 1
  fi
}

# List free IP ports.
ip_free_ports() {
  register_temp_cleanup
  local port="$1"
  local end="$2"
  local priv_ports_path="$TEMP_DIR"/f5c41b5
  seq "$port" "$end" >"$priv_ports_path"
  local used_ports_path="$TEMP_DIR"/6157e29
  ip_ports_in_use >"$used_ports_path"
  comm -23 "$priv_ports_path" "$used_ports_path"
}

ip_random_free_port() {
  local start=49152
  local end=65535
  local number=1
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (start) start="$OPTARG";;
      (end) end="$OPTARG";;
      (number) number="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))
  ip_free_ports "$start" "$end" | shuf | head -n "$number"
}
