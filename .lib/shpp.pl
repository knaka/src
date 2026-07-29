#!/usr/bin/env perl
# vim: set tabstop=2 shiftwidth=2 et:
# -*- mode: perl; tab-width: 2; indent-tabs-mode: nil; -*-

use strict;
use warnings;
use v5.10;
use experimental qw{switch vlb};
use File::Basename qw(basename);

my $source_guard_tmpl = (<<'EOF' =~ s/\R$//r);
set -- __UNIQUE_ID_ "$@"; eval "shift; \${$1-false} || ! $1=true" && return || :
EOF

my $begin_source_tmpl = (<<'EOF' =~ s/\R$//r);
if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR _DIR_ "$OLDPWD" "$@"
EOF

my $end_source_tmpl = (<<'EOF' =~ s/\R$//r);
cd "$3" || exit; shift 3
EOF

my $main_guard_tmpl = (<<'EOF' =~ s/\R$//r);
if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (_BASE_.*) ;; (*) false;; esac
EOF

our $last = "_c4e448e_";

sub puts {
  my ($line) = @_;
  my @lines = split /(?<=\R)/, $line;
  return unless @lines;
  my $new_last = $lines[-1];
  shift @lines if $lines[0] eq $last;
  for my $l (@lines) {
    print "$l";
  }
  $last = $new_last;
}

sub shpp {
  my $rand = rand(0xFFFFFFF) + 1;
  my $rand7 = sprintf("%x", $rand);
  my $finding_dir = "";
  while (<>) {
    given ($_) {
      when (/^\. (.*)/) {
        my $dir = ($1 =~ s@/[^/]+$@@r);
        my $s = ($finding_dir =~ s/_DIR_/$dir/gr);
        $finding_dir = "";
        puts "$s";
        continue;
      }
      when (/^\s*$/s) {
        puts $_;
      }
      when (/^.*( #\s*shpp:source_guard\b.*)$/s) {
        my $trailing = $1;
        my $unique_id = "";
        $unique_id = ($ARGV =~ s/[^a-zA-Z0-9]/_/gr =~ y/[a-z]/[A-Z]/r);
        my $source_guard = $source_guard_tmpl =~ s/_UNIQUE_ID_/$unique_id/gr;
        puts "$source_guard$trailing";
      }
      when (/^.*( #\s*shpp:sources\b.*)/s) {
        my $trailing = $1;
        # my $begin_source = ($begin_source_tmpl =~ s/_DIR_/???/gr);
        # puts "$begin_source$trailing";
        $finding_dir = "$begin_source_tmpl$trailing";
      }
      when (m@^.*( #\s*/shpp:sources\b.*)@s) {
        my $trailing = $1;
        my $stms = $end_source_tmpl;
        puts "$stms$trailing";
      }
      when (/^.*( #\s*shpp:main_guard.*)/s) {
        my $trailing = $1;
        my $base = (basename($ARGV) =~ s/\..*$//r);
        my $base1 = $base =~ s/[^a-zA-Z0-0]/_/gr;
        my $base2 = $base =~ s/[^a-zA-Z0-0]/-/gr;
        my $main_guard = ($main_guard_tmpl =~ s/_BASE_/$base/gr);
        # if ($base1 ne $base2) {
        #   $main_guard .= " || _ $base2";
        # }
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
