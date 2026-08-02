#!/usr/bin/env bash
set -- _e055cef "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# `-d` is Bash specific.
script_244dbcd=; IFS='' read -r -d '' script_244dbcd <<'EOF_1195B76' || :
my $text = (<<'EOF' =~ s/\R$//r);
Hello
Foo Bar
EOF

sub main {
  print STDERR "<${text}>\n";
  for my $i (0 .. $#ARGV) {
    print "Argument $i is: $ARGV[$i]\n";
  }
}

main() unless caller;
EOF_1195B76

heredoc_script() {
  perl -e "$script_244dbcd" "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  set -o pipefail
  heredoc_script foo bar
fi
