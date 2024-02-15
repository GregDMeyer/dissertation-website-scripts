#!/usr/bin/env bash

set -ex

# TODO: make this script runnable from anywhere?

mkdir -p tmp-files/

# get various files from engrafo
docker run -it --rm -v $PWD:/workdir engrafo \
    cp -r \
        /app/latexml/packages/ \
        /app/latexml/engrafo.ltxml \
        /workdir/tmp-files/
docker run -it --rm -v $PWD:/workdir engrafo \
    cp -r /app/dist/css/index.css /workdir/tmp-files/index-tmp.css
docker run -it --rm -v $PWD:/workdir engrafo \
    cp -r /app/dist/javascript/index.js /workdir/tmp-files/index.js
# TODO: rename index.css and index.js?

# put my custom verbatim code there too
cp scripts/*.xsl tmp-files/

# add extra css
cat scripts/extra.css tmp-files/index-tmp.css > tmp-files/index.css
cp scripts/extra.js tmp-files/

# TeX -> XML
docker run -it --rm -v $PWD:/workdir latexml-git \
   latexml \
       --path=tmp-files/packages/ \
       --path=tmp-files/ \
       --preload=tmp-files/engrafo.ltxml \
       --destination=web/index.xml \
       tex/main.tex

# fix some stuff (currently just making conclusion not in Part II)
python scripts/fix_xml.py web/index.xml

# XML -> HTML
docker run -it --rm -v $PWD:/workdir latexml-git \
    latexmlpost \
        --format=html5 \
        --splitat=chapter \
        --urlstyle=file \
        --mathtex \
        --javascript='https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js' \
        --javascript='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/highlight.min.js' \
        --javascript='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@latest/build/languages/julia.min.js' \
        --javascript='tmp-files/extra.js' \
        --timestamp=0 \
        --nodefaultresources \
        --path=tmp-files/packages/ \
        --path=tmp-files/ \
        --stylesheet=tmp-files/verbatim_precode.xsl \
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
    python scripts/fix_html.py $file
done
