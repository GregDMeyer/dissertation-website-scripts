'''
This script takes the HTML produced by latexmlpost and makes some changes to it.
'''

from sys import argv
from bs4 import BeautifulSoup


def replace(match):
    index = match.group(1)
    if index.startswith('I'):
        return 'Part '+index+'</a'

    return 'Chapter '+index+'</a'


output_lines = []
with open(argv[1]) as f:
    f_iter = iter(f)
    for line in f_iter:
        # skip the header and footer of index.html
        if 'index.html' in argv[1] and any(s in line for s in ('<header', '<footer')):
            line = next(f_iter)
            while not any(s in line for s in ('</header', '</footer')):
                line = next(f_iter)
            continue

        # shorten the names of chapters and parts in the header links
        if line.startswith('<a ') and line.endswith('/a>\n'):
            soup = BeautifulSoup(line, 'html.parser')
            for a_node in soup.find_all('a'):
                if 'rel' not in a_node.attrs:
                    continue

                if not(a_node['title'].startswith('Exploring the ') or a_node['title'].startswith('Part') or a_node['title'].startswith('Chapter')):
                    continue

                if a_node['title'].startswith('Part') or a_node['title'].startswith('Chapter'):
                    a_node.span.span.decompose()
                    new_content = ' '.join(a_node['title'].split(' ')[:2])
                else:     # top level
                    if 'prev' in a_node['rel']:
                        a_node.decompose()
                        continue
                    new_content = 'Table of Contents'

                a_node.span.string = new_content

            line = soup.prettify(formatter='html5')

        output_lines.append(line)


with open(argv[1], 'w') as f:
    f.write(''.join(output_lines))
