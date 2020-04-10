# Landini-Stolfi and Zandbergen's transcriptions
EVA_CORPORA = beta/LSI_ivtff_0d.txt ZL_ivtff_1z.txt
EMB_DIM?=10
EMB_MODE?=skipgram
EMB_EPOCH?=10000
EMB_CORPUS?=voynich
HERBS_CORPUS = plantsstoriesof00alleuoft/plantsstoriesof00alleuoft_djvu \
               gardenofherbsbei00rohdrich/gardenofherbsbei00rohdrich_djvu \
               vgmuseum_miscgame_towerofsouls-herbs/towerofsouls-herbs_djvu \
               darwin-online_1865_plants_F834a/1865_plants_F834a_djvu \
               culinaryherbs00kain/culinaryherbs00kain_djvu \
               HerbsForCommonAilments/Herbs%20for%20Common%20Ailments_djvu \
               bookofherbs00nort/bookofherbs00nort_djvu \
               growingsavoryher00chip/growingsavoryher00chip_djvu \
               b2040640x/b2040640x_djvu \
               b20411303/b20411303_djvu \
               b20405297/b20405297_djvu \
               plants1903frui/plants1903frui_djvu \
               TravancorePlants/TravancorePlants_djvu \
               in.ernet.dli.2015.217803/2015.217803.Plants_djvu \
               jstor-2447080/2447080_djvu \
               jstor-2447496/2447496_djvu \
               jstor-2449275/2449275_djvu \
               in.ernet.dli.2015.222841/2015.222841.Climbing-Plants_djvu \
               AncientPlantsOfIndia/Ancient%20Plants%20of%20India_djvu \
               in.ernet.dli.2015.47629/2015.47629.Bengal-Plants_djvu \
               CAT31323436/cat31323436_djvu \
               ornamentalplants46muns/ornamentalplants46muns_djvu \
               PlantsWithPersonality/PlantPersonality_djvu \
               philtrans01416553/01416553_djvu

.PHONY: embeddings

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

herbs: $(HERBS_CORPUS)

$(HERBS_CORPUS):
	wget -qO- "https://archive.org/stream/$@.txt" | \
	grep -Pzo '(?s)(?<=<pre>)(.*?)(?=</pre>)' | \
	sed 's/([^-])$$/\0 /g; s/-\s*$$//' | \
	tr '\n' ' ' | tr '[:upper:]' '[:lower:]' >> corpora/herbs.txt

embeddings: bin/fasttext
	mkdir -p embeddings
	./bin/fasttext ${EMB_MODE} \
	               -input corpora/${EMB_CORPUS}.txt \
	               -output embeddings/${EMB_CORPUS}_${EMB_MODE}_${EMB_DIM} \
	               -dim ${EMB_DIM} \
	               -epoch ${EMB_EPOCH}
