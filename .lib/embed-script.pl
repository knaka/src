#!/usr/bin/env perl
# vim: set tabstop=2 shiftwidth=2 et:
# -*- mode: perl; tab-width: 2; indent-tabs-mode: nil; -*-

# Embeds minified file contents into shell-script files.
#
# Scans each input file line by line for #EMBED directives. A line of the
# form:
#   'original content' #EMBED: path/to/file
# has the content between the quotes replaced with the minified contents of
# the referenced file, keeping the #EMBED comment so it can be re-run later.
#
# Usage:
#   embed-script.pl input_file... >output_file
#
# Supported file types for minification:
#   .awk  - Strips comments and leading whitespace, appends semicolons
#   .jq   - Strips comments, collapses leading whitespace to a single space
#   .py   - Strips comments and blank lines, appends semicolons
#           (works only for one-liner-friendly Python: no multi-line control
#           structures, one statement per line)
#   other - Lines are joined verbatim

use v5.11;
use strict;
use warnings;
use File::Basename qw(dirname basename);

binmode STDOUT;

# Extension => per-line minifier. Each minifier takes one chomped line and
# returns the replacement line, or undef to drop the line entirely.
my %MINIFIER_OF_EXT = (
  '.awk' => \&minify_awk_line,
  '.jq'  => \&minify_jq_line,
  '.py'  => \&minify_py_line,
);

sub minify_awk_line {
  local $_ = shift;
  s/^\s*#.*//;
  s/^\s*//;
  s/([^{};])$/$1;/;
  return $_;
}

sub minify_jq_line {
  local $_ = shift;
  s/^\s*#.*//;
  s/^\s+/ /;
  return $_;
}

sub minify_py_line {
  local $_ = shift;
  return undef if /^\s*#/;
  s/^\s*//;
  return undef if $_ eq '';
  $_ .= ';' unless /[:;]$/;
  return $_;
}

# Reads a file and returns its contents minified onto a single line, using
# the minifier for the file's extension (unrecognized extensions are just
# joined as-is).
sub minify {
  my ($path) = @_;
  my ($ext) = basename($path) =~ /.(\.[^.]+)$/;
  my $minifier = $ext && $MINIFIER_OF_EXT{$ext};

  open my $fh, '<', $path or die "$path: $!\n";
  my $minified = '';
  while (my $line = <$fh>) {
    chomp $line;
    $line = $minifier->($line) if $minifier;
    $minified .= $line if defined $line;
  }
  return $minified;
}

# Matches "'content' #EMBED: path" or '"content" #EMBED: path', capturing
# everything up to and including the opening quote (pre), the closing quote
# through "#EMBED:" (post), and the path. The content between the quotes is
# discarded and replaced with the minified file.
my $EMBED_SINGLE = qr/^(?<pre>[^']*')[^']*(?<post>'.*#EMBED:\s*)(?<path>.+)$/;
my $EMBED_DOUBLE = qr/^(?<pre>[^"]*")[^"]*(?<post>".*#EMBED:\s*)(?<path>.+)$/;

sub embed_path_for {
  my ($dir, $path) = @_;
  return $path =~ m{^/} ? $path : "$dir/$path";
}

sub process_file {
  my ($filepath) = @_;
  my $dir = dirname($filepath);

  open my $fh, '<', $filepath or die "$filepath: $!\n";
  while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ $EMBED_SINGLE || $line =~ $EMBED_DOUBLE) {
      my ($pre, $post, $path) = @+{qw(pre post path)};
      print $pre, minify(embed_path_for($dir, $path)), $post, $path, "\n";
    } else {
      print "$line\n";
    }
  }
}

process_file($_) for @ARGV;
