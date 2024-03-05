'''
This script processes the XML output from latexml. Currently it just ends Part II earlier.
'''

from sys import argv

filename = argv[1]

chapter_counter = 0
next_after_chapter = False

result_lines = []
with open(filename) as f:
    for line in f:
        if next_after_chapter and chapter_counter == 8:
            result_lines.append('</part>\n')
        elif chapter_counter > 8 and '</part>' in line:
            next_after_chapter = False
            continue

        if '</chapter' in line:
            chapter_counter += 1
            next_after_chapter = True
        else:
            next_after_chapter = False

        line = line.replace('%&#10;', '')

        result_lines.append(line)

# write it back out to the input file
with open(filename, 'w') as f:
    f.write(''.join(result_lines))
