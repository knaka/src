use File::Basename;
use File::Spec;

sub minify {
  my ($path) = @_;
  open(my $fh, '<', $path) or die "Cannot open $path: $!";
  my @lines = <$fh>;
  close($fh);
  chomp(@lines);
  my $string;
  if ($path =~ /\.awk$/) {
    # Remove comments.
    @lines = map { s/^\s*#.*//; $_ } @lines;
    # Remove preceding spaces.
    @lines = map { s/^\s*//; $_ } @lines;
    # Append `;`
    @lines = map { s/([^{};])$/$1;/; $_ } @lines;
  } elsif ($path =~ /\.jq$/) {
    # Remove comments.
    @lines = map { s/^\s*#.*//; $_ } @lines;
    # Remove preceding spaces.
    @lines = map { s/^\s+/ /; $_ } @lines;
  }
  $string = join('', @lines);
  # $string = join('', @lines);
  return $string;
}

if (/^(?<pre>[^']*')[^']*(?<post>'.*#EMBED:\s*)(?<path>.+)$/) {
  $path = "$+{path}";
  if (!File::Spec->file_name_is_absolute($path)) {
    $path = File::Spec->catfile(dirname($ARGV), $path);
  }
  $minified = minify($path);
  print "$+{pre}$minified$+{post}$+{path}\n";
} else {
  print;
}
