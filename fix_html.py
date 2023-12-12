'''
This script takes the HTML produced by latexmlpost and makes some changes to it.
'''

from sys import argv
import bs4

with open(argv[1]) as f:
    tree = bs4.BeautifulSoup(f, 'html.parser')

for a_node in tree.find_all('a'):
    if 'rel' not in a_node.attrs:
        continue

    if not('up' in a_node['rel'] or a_node['title'].startswith('Part') or a_node['title'].startswith('Chapter')):
        continue

    print(a_node)

    if a_node['title'].startswith('Part') or a_node['title'].startswith('Chapter'):
        new_content = ' '.join(a_node['title'].split(' ')[:2])
    else:     # top level
        new_content = 'Top level'
    a_node.span.span.decompose()
    a_node.span.string = new_content

with open(argv[1], 'w') as f:
    f.write(tree.prettify(formatter='html5'))
