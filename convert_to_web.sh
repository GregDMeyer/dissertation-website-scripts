#!/usr/bin/env bash

set -ex

# TODO: make this script runnable from anywhere?

mkdir -p tmp-files/

# # get various files from engrafo
# docker run -it --rm -v $PWD:/workdir engrafo \
#     cp -r \
#         /app/latexml/packages/ \
#         /app/latexml/engrafo.ltxml \
#         /workdir/tmp-files/
# docker run -it --rm -v $PWD:/workdir engrafo \
#     cp -r /app/dist/css/index.css /workdir/tmp-files/index.css
# docker run -it --rm -v $PWD:/workdir engrafo \
#     cp -r /app/dist/javascript/index.js /workdir/tmp-files/index.js
# # TODO: rename index.css and index.js?

# # TeX -> XML
# docker run -it --rm -v $PWD:/workdir latexml \
#    latexml \
#        --path=tmp-files/packages/ \
#        --preload=tmp-files/engrafo.ltxml \
#        --destination=web/index.xml \
#        tex/main.tex

# # fix some stuff (currently just making conclusion not in Part II)
# python scripts/fix_xml.py web/index.xml

# XML -> HTML
docker run -it --rm -v $PWD:/workdir latexml \
    latexmlpost \
        --format=html5 \
        --splitat=chapter \
        --urlstyle=file \
        --mathtex \
        --javascript='https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js' \
        --timestamp=0 \
        --nodefaultresources \
        --path=tmp-files/packages/ \
        --javascript=tmp-files/index.js \
        --css=tmp-files/index.css \
        --xsltparameter=SIMPLIFY_HTML:true \
        --destination=web/index.html \
        web/index.xml

# run engrafo on the resulting HTML
# note this uses my modified engrafo, not the regular one!
for file in $(ls web/*.html); do
    docker run -it --rm -v $PWD:/workdir -w /workdir engrafo \
       engrafo \
       $file
    #python scripts/fix_html.py $file
done
