# Landini-Stolfi and Zandbergen's transcriptions
EVA_CORPUS = beta/LSI_ivtff_0d.txt ZL_ivtff_1z.txt

$(EVA_CORPORA):
	mkdir -p tmp corpora
	wget "http://www.voynich.nu/data/$@" -O "tmp/$(notdir $@)"
	./preprocess.py tmp/$(notdir $@) >> corpora/voynich.txt

voynich: $(EVA_CORPUS)
