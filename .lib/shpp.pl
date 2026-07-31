#!/usr/bin/env perl
# vim: set tabstop=2 shiftwidth=2 et:
# -*- mode: perl; tab-width: 2; indent-tabs-mode: nil; -*-

require strict;
# 0x2 is strict refs, 0x200 is strict subs, and 0x400 is strict vars.
sub is_strict_enabled { ((caller(0))[8] & strict::all_bits()) == strict::all_bits(); }

require warnings;
sub is_warnings_enabled {
  my @c = caller(0);
  my $bitmask = $c[9];
  return 0 unless defined $bitmask;
  my $all = $warnings::Bits{all};
  my $len = length($all);
  $bitmask = substr($bitmask . ("\0" x $len), 0, $len);
  return ($bitmask & $all) eq $all;
}

use v5.11;

# A version declaration of v5.11 or higher (such as `use v5.11;` or `use 5.011;`) automatically enables `use strict`, along with matching features for that release, on Perl implementation 5.12 or higher.
# use strict;
exit(2) unless is_strict_enabled;

# Declaring v5.35 or higher automatically enables `use warnings`; the checking was added after Perl 5.36.
use warnings;
exit(3) unless is_warnings_enabled;

use experimental qw{switch vlb};
use File::Basename qw(basename);

my $source_guard_tmpl = (<<'EOF' =~ s/\R$//r);
set -- _@UNIQUE_ID@ "$@"; eval "shift; \${$1-false} || ! $1=true" && return
EOF

my $begin_source_tmpl = (<<'EOF' =~ s/\R$//r);
if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR _DIR_ "$OLDPWD" "$@"
EOF

my $end_source_tmpl = (<<'EOF' =~ s/\R$//r);
cd "$3" || exit; shift 3
EOF

my $main_guard_tmpl = (<<'EOF' =~ s/\R$//r);
if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (_BASE_.*) ;; (*) false;; esac
EOF

# our - Perldoc Browser https://perldoc.perl.org/functions/our
our $last = "_c4e448e_";

sub puts {
  my ($line) = @_;
  print "$line" if "$line" ne "$last";
  $last = $line;
}

sub shpp {
  my $rand = rand(0xFFFFFFF) + 1;
  my $rand7 = sprintf("%x", $rand);
  my $finding_dir = "";
  while (<>) {
    given ($_) {
      # Sourcing.
      when (/^\. (.*)/) {
        my $dir = ($1 =~ s@/[^/]+$@@r);
        my $s = ($finding_dir =~ s/_DIR_/$dir/gr);
        $finding_dir = "";
        puts "$s";
        continue;
      }
      # Empty.
      when (/^\s*$/s) {
        puts $_;
      }
      when (/^[^\s].*( #\s*shpp:source_guard\b.*)$/s) {
        my $trailing = $1;
        my $unique_id = "";
        $unique_id = ($ARGV =~ s/[^a-zA-Z0-9]/_/gr =~ y/[a-z]/[A-Z]/r);
        my $source_guard = $source_guard_tmpl =~ s/\@UNIQUE_ID\@/$unique_id/gr;
        puts "$source_guard$trailing";
      }
      when (/^[^\s].*( #\s*shpp:sources\b.*)/s) {
        my $trailing = $1;
        # my $begin_source = ($begin_source_tmpl =~ s/_DIR_/???/gr);
        # puts "$begin_source$trailing";
        $finding_dir = "$begin_source_tmpl$trailing";
      }
      when (m@^[^\s].*( #\s*/shpp:sources\b.*)@s) {
        my $trailing = $1;
        my $stms = $end_source_tmpl;
        puts "$stms$trailing";
      }
      when (/^[^\s].*( #\s*shpp:main_guard.*)/s) {
        my $trailing = $1;
        my $base = (basename($ARGV) =~ s/\..*$//r);
        my $main_guard = ($main_guard_tmpl =~ s/_BASE_/$base/gr);
        puts "$main_guard$trailing";
      }
      default {
        puts "$_";
      }
    }
    close(ARGV) if eof;
  }
}

shpp() unless caller;
