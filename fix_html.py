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


def main():
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
            if line.startswith('<a '):
                while '</a>' not in line:
                    line += next(f_iter)
                soup = BeautifulSoup(line, 'html.parser')
                for a_node in soup.find_all('a'):
                    if 'rel' not in a_node.attrs:
                        continue

                    title = parse_href(a_node['href'])
                    if title is None:
                        continue

                    if 'Part' in title or 'Chapter' in title:
                        a_node.span.span.decompose()
                    else:     # top level
                        if 'prev' in a_node['rel']:
                            a_node.decompose()
                            continue

                    a_node.span.string = title

                line = soup.prettify(formatter='html5')

            output_lines.append(line)


    with open(argv[1], 'w') as f:
        f.write(''.join(output_lines))


def parse_href(val):
    if val == 'index.html':
        return 'Table of Contents'

    num = val[2:][:-5]
    if 'x' in num:
        return None

    if val.startswith('Pt'):
        return 'Part ' + 'I'*int(num)
    elif val.startswith('Ch'):
        return f'Chapter {num}'
    else:
        return None


if __name__ == '__main__':
    main()
