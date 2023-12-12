'''
This script takes the HTML produced by latexmlpost and makes some changes to it.
'''

# we use regex to parse HTML, despite the fact that it
# is generally not recommended:
# https://stackoverflow.com/questions/1732348/regex-match-open-tags-except-xhtml-self-contained-tags/1732454#1732454

from sys import argv
import re

def replace(match):
    index = match.group(1)
    if index.startswith('I'):
        return 'Part '+index+'</a'

    return 'Chapter '+index+'</a'

output_lines = []
with open(argv[1]) as f:
    for line in f:
        output_lines.append(re.sub(r'<span class="ltx_tag ltx_tag_ref">([I0-9]*) </span>.*?</span></a', replace, line))

with open(argv[1], 'w') as f:
    f.write(''.join(output_lines))
