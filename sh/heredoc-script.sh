#!/usr/bin/env dash
set -- _bff3b36 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null && set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit && shift 3 # /shpp:sources

script_bfeda5a=

assign_stdin script_bfeda5a <<'EOF_1DB5678'
my $text = (<<'EOF' =~ s/\R$//r);
Hello, Dash
Foo Bar
EOF

sub main {
  print STDERR "<${text}>\n";
  for my $i (0 .. $#ARGV) {
    print "Argument $i is: $ARGV[$i]\n";
  }
}

main() unless caller;
EOF_1DB5678

perl -e "$script_bfeda5a" foo bar
