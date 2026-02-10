# embed.pl - Embeds minified file contents into shell-script files
#
# This script processes input files line by line, looking for #EMBED directives.
# When a line matches the pattern:
#   'original content' #EMBED: path/to/file
# It replaces the content between quotes with the minified contents of the
# referenced file, preserving the #EMBED comment for future updates.
#
# Usage:
#   perl embed.pl input_file >output_file
#
# Supported file types for minification:
#   .awk - Removes comments, leading whitespace, and appends semicolons
#   .jq  - Removes comments and collapses leading whitespace to single space
#   Other files - Joins lines without modification

use File::Basename;
use File::Spec;

# Reads a file and returns its contents as a single line.
# Applies minification rules to reduce size.
# Arguments:
#   $path - Path to the file to read
# Returns:
#   String with file contents joined into a single line
sub minify {
  my ($path) = @_;
  open(my $fh, '<', $path) or die "Cannot open $path: $!";
  my @lines = <$fh>;
  close($fh);
  chomp(@lines);
  my $string;
  if ($path =~ /\.awk$/) {
    # AWK minification:
    # 1. Remove comment lines (lines starting with optional whitespace and #)
    @lines = map { s/^\s*#.*//; $_ } @lines;
    # 2. Remove all leading whitespace from each line
    @lines = map { s/^\s*//; $_ } @lines;
    # 3. Append semicolon to lines not ending with {, }, or ;
    #    This ensures statements are properly terminated when joined
    @lines = map { s/([^{};])$/$1;/; $_ } @lines;
  } elsif ($path =~ /\.jq$/) {
    # jq minification:
    # 1. Remove comment lines
    @lines = map { s/^\s*#.*//; $_ } @lines;
    # 2. Collapse leading whitespace to single space (preserves structure)
    @lines = map { s/^\s+/ /; $_ } @lines;
  }
  # Join all lines without separator
  $string = join('', @lines);
  return $string;
}

# Main processing loop
# Reads input files line by line and processes #EMBED directives.
# Matches lines with pattern: 'content' #EMBED: path
# Captures:
#   pre  - Everything up to and including the first single quote
#   post - The closing quote through #EMBED: (content between quotes is replaced)
#   path - The file path to embed
while (<>) {
  if (/^(?<pre>[^']*')[^']*(?<post>'.*#EMBED:\s*)(?<path>.+)$/) {
    $path = "$+{path}";
    # Resolve relative paths based on the directory of the input file
    if (!File::Spec->file_name_is_absolute($path)) {
      $path = File::Spec->catfile(dirname($ARGV), $path);
    }
    $minified = minify($path);
    # Output: prefix + minified content + suffix (including original path)
    print "$+{pre}$minified$+{post}$+{path}\n";
  } else {
    # Pass through lines without #EMBED directive unchanged
    print;
  }
}
