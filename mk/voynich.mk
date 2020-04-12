# Zandbergen's transcriptions
ZL_ivtff_1z.txt:
	mkdir -p tmp corpora
	wget "http://www.voynich.nu/data/$@" -O "tmp/$(notdir $@)"
	./preprocess.py tmp/$(notdir $@) >> corpora/voynich.txt

voynich: ZL_ivtff_1z.txt
