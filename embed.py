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
#   Other files - Joins lines without modification

import re
import sys
from pathlib import Path

def minify(path: str) -> str:
    """
    Reads a file and returns its contents as a single line.
    Applies minification rules to reduce size.

    Args:
        path: Path to the file to read

    Returns:
        String with file contents joined into a single line
    """
    with open(path, 'r') as f:
        lines = [line.rstrip('\n') for line in f]

    if path.endswith('.awk'):
        # AWK minification:
        # 1. Remove comment lines (lines starting with optional whitespace and #)
        lines = [re.sub(r'^\s*#.*', '', line) for line in lines]
        # 2. Remove all leading whitespace from each line
        lines = [re.sub(r'^\s*', '', line) for line in lines]
        # 3. Append semicolon to lines not ending with {, }, or ;
        #    This ensures statements are properly terminated when joined
        lines = [re.sub(r'([^{};])$', r'\1;', line) for line in lines]
    elif path.endswith('.jq'):
        # jq minification:
        # 1. Remove comment lines
        lines = [re.sub(r'^\s*#.*', '', line) for line in lines]
        # 2. Collapse leading whitespace to single space (preserves structure)
        lines = [re.sub(r'^\s+', ' ', line) for line in lines]

    # Join all lines without separator
    return ''.join(lines)


# Main processing loop
# Reads input files line by line and processes #EMBED directives.
# Matches lines with pattern: 'content' #EMBED: path
# Captures:
#   pre  - Everything up to and including the first single quote
#   post - The closing quote through #EMBED: (content between quotes is replaced)
#   path - The file path to embed
EMBED_PATTERN = re.compile(r"^(?P<pre>[^']*')[^']*(?P<post>'.*#EMBED:\s*)(?P<path>.+)$")

if __name__ == '__main__':
    for filepath in sys.argv[1:]:
        input_path = Path(filepath)
        with open(input_path, 'r') as f:
            for line in f:
                match = EMBED_PATTERN.match(line)
                if match:
                    embed_path = match.group('path')
                    # Resolve relative paths based on the directory of the input file
                    if not Path(embed_path).is_absolute():
                        embed_path = str(input_path.parent / embed_path)
                    minified = minify(embed_path)
                    # Output: prefix + minified content + suffix (including original path)
                    print(f"{match.group('pre')}{minified}{match.group('post')}{match.group('path')}")
                else:
                    # Pass through lines without #EMBED directive unchanged
                    print(line, end='')
