#!/usr/bin/env sh
set -- __LIB_SHPP_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
script_path_ccd23eb="$PWD"/shpp.pl
cd "$3" || exit; shift 3 # /shpp:sources

script_ed0985e=

shpp() {
  if test -r "$script_path_ccd23eb"
  then
    perl "$script_path_ccd23eb" "$@"
  else
    load_f35a07c
    perl -e "$script_ed0985e" -- "$@"
  fi
}

#EMBED: ./shpp.pl
load_f35a07c() { while IFS= read -r REPLY || test -n "$REPLY"; do script_ed0985e="$script_ed0985e${REPLY}$CH_LF"; done <<'EOF_E6274B4'
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
# exit(3) unless is_warnings_enabled;

use experimental qw{switch vlb};
use File::Basename qw(basename);
use File::Spec ();
use Cwd qw(abs_path);
use Text::ParseWords qw(shellwords);
use Getopt::Long qw(GetOptions);
use File::Temp qw(tempfile);
use File::Compare qw(compare);
use File::Copy qw(copy);

use Data::Dumper qw(Dumper);
local $Data::Dumper::Sortkeys = 1;
local $Data::Dumper::Terse = 1;
local $Data::Dumper::Indent = 0;

# A minimal scope-guard: runs $code when the returned object is destroyed,
# i.e. when it goes out of scope, whether by normal return, early return, or
# die-triggered stack unwinding.
package ScopeGuard;
sub new { my ($class, $code) = @_; return bless { code => $code }, $class; }
sub DESTROY { my $self = shift; $self->{code}->(); }
package main;

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
  my $in_place = 0;
  GetOptions(
    'i|in-place' => \$in_place,
  ) or exit(1);
  if ($in_place && !@ARGV) {
    print STDERR "No file specified for --in-place\n";
    exit(1);
  }

  my $rand = rand(0xFFFFFFF) + 1;
  my $rand7 = sprintf("%x", $rand);
  my $finding_dir = "";

  my ($tmp_fh, $tmp_filename);
  my $tmp_guard;
  if ($in_place) {
    ($tmp_fh, $tmp_filename) = tempfile(UNLINK => 1);
    select($tmp_fh);
    $tmp_guard = ScopeGuard->new(sub {
      select(STDOUT);
      close($tmp_fh) if $tmp_fh;
      unlink($tmp_filename) if defined $tmp_filename && -e $tmp_filename;
    });
  }

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
      when (/^[^\s].*( #\s*shpp:source_guard\b\s*(.*))$/s) {
        my $trailing = $1;
        my $params = $2;
        my @words = shellwords($params);
        # print STDERR Dumper(\@words);
        my $unique_id;
        for my $word (@words) {
          my @fields = split /=/, $word;
          $unique_id = $fields[1] if grep { $_ eq $fields[0] } qw(id uid unique_id);
        }
        $unique_id //= do {
          my $rel = File::Spec->abs2rel(abs_path($ARGV));
          $rel =~ s{^\./}{};
          ($rel =~ s/[^a-zA-Z0-9]/_/gr =~ y/[a-z]/[A-Z]/r);
        };
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
    if (eof) {
      if ($in_place) {
        select(STDOUT);
        close($tmp_fh);
        my $file = $ARGV;
        if (compare($tmp_filename, $file) != 0) {
          copy($tmp_filename, $file) or die "$tmp_filename -> $file: $!";
        }
        unlink($tmp_filename);
        ($tmp_fh, $tmp_filename) = tempfile(UNLINK => 1);
        select($tmp_fh);
      }
      close(ARGV);
    }
  }
}

shpp() unless caller;
EOF_E6274B4
}
