# embed.py - Embeds minified file contents into shell-script files
#
# This script processes input files line by line, looking for #EMBED directives.
# When a line matches the pattern:
#   'original content' #EMBED: path/to/file
# It replaces the content between quotes with the minified contents of the
# referenced file, preserving the #EMBED comment for future updates.
#
# Usage:
#   python embed.py input_file >output_file
#
# Supported file types for minification:
#   .awk - Removes comments, leading whitespace, and appends semicolons
#   .jq  - Removes comments and collapses leading whitespace to single space

import re
import sys
from pathlib import Path


def minify(path: Path) -> str:
    """
    Reads a file and returns its contents as a single line.
    Applies minification rules based on file extension.

    Args:
        path: Path to the file to read

    Returns:
        String with file contents joined into a single line
    """

    with open(path, 'r') as f:
        lines = [line.rstrip('\n') for line in f]

    ext = path.suffix
    match ext:
        case '.awk':
            lines = [
                re.sub(r'([^{};])$', r'\1;',
                    re.sub(r'^\s*', '',
                        re.sub(r'^\s*#.*', '', line)))
                for line in lines
            ]
        case '.jq':
            lines = [
                re.sub(r'^\s+', ' ',
                    re.sub(r'^\s*#.*', '', line))
                for line in lines
            ]
        case _:
            raise ValueError(f"Unsupported file extension: {ext}")

    # Join all lines without separator
    return ''.join(lines)


# Matches lines with pattern: 'content' #EMBED: path
# Captures:
#   pre  - Everything up to and including the first single quote
#   post - The closing quote through #EMBED: (content between quotes is replaced)
#   path - The file path to embed
EMBED_PATTERN = re.compile(r"^(?P<pre>[^']*')[^']*(?P<post>'.*#EMBED:\s*)(?P<path>.+)$")


def process_line(line: str, input_path: Path) -> None:
    """Process a single line, printing the result."""

    match = EMBED_PATTERN.match(line)
    if not match:
        print(line, end='')
        return

    embed_path = Path(match.group('path'))
    # Resolve relative paths based on the directory of the input file
    if not embed_path.is_absolute():
        embed_path = input_path.parent / embed_path

    minified = minify(embed_path)
    # Output: prefix + minified content + suffix (including original path)
    print(f"{match.group('pre')}{minified}{match.group('post')}{match.group('path')}")


def process_file(filepath: str) -> None:
    """Process a single file, replacing #EMBED directives with minified content."""

    input_path = Path(filepath)
    with open(input_path, 'r') as f:
        for line in f:
            process_line(line, input_path)


if __name__ == '__main__':
    for filepath in sys.argv[1:]:
        process_file(filepath)
