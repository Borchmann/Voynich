# Landini-Stolfi and Zandbergen's transcriptions
EVA_CORPORA = beta/LSI_ivtff_0d.txt ZL_ivtff_1z.txt

corpora: $(EVA_CORPORA)

clean:
	rm -rf tmp corpora

$(EVA_CORPORA):
	mkdir -p tmp corpora
	wget "http://www.voynich.nu/data/$@" -O "tmp/$(notdir $@)"
	./preprocess.py tmp/$(notdir $@) > corpora/$(notdir $@)
