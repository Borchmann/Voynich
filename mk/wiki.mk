DUMP = 20200401/enwiki-20200401-pages-articles-multistream.xml.bz2

tmp/wiki.xml.bz2:
	wget "https://dumps.wikimedia.org/enwiki/${DUMP}" -O tmp/wiki.xml.bz2

bin/wikiextractor:
	wget https://raw.githubusercontent.com/attardi/wikiextractor/master/WikiExtractor.py -O bin/wikiextractor
	chmod 777 bin/wikiextractor

corpora/wiki.txt: bin/wikiextractor tmp/wiki.xml.bz2
	./bin/wikiextractor --processes 10 -o - tmp/wiki.xml.bz2 | \
	grep "^[^<]" wiki.txt | fgrep '.' | \
	python -m syntok.segmenter | python -m syntok.tokenizer | \
	tr '[:upper:]' '[:lower:]' | ftfy | tr '[:punct:]' ' ' | \
	sed -E 's/[0-9]+/9/g; s/\s\s+/ /g' > 

wiki: corpora/wiki.txt
