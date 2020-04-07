# Landini-Stolfi and Zandbergen's transcriptions
EVA_CORPORA = beta/LSI_ivtff_0d.txt ZL_ivtff_1z.txt
EMB_DIM?=10
EMB_MODE?=skipgram
EMB_EPOCH?=10000

clean:
	rm -rf tmp corpora

corpora: $(EVA_CORPORA)

$(EVA_CORPORA):
	mkdir -p tmp corpora
	wget "http://www.voynich.nu/data/$@" -O "tmp/$(notdir $@)"
	./preprocess.py tmp/$(notdir $@) >> corpora/voynich.txt

.ONESHELL:
bin/fasttext:
	mkdir -p bin
	cd tmp
	wget https://github.com/facebookresearch/fastText/archive/v0.9.1.zip
	unzip v0.9.1.zip
	cd fastText-0.9.1
	make
	mv fasttext ../bin/

embeddings/voynich: bin/fasttext
	mkdir -p embeddings
	./bin/fasttext ${EMB_MODE} \
	               -input corpora/voynich.txt \
				   -output embeddings/voynich_${EMB_MODE}_${EMB_DIM} \
				   -dim ${EMB_DIM} \
				   -epoch ${EMB_EPOCH}
