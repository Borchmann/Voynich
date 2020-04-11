EMB_DIM?=10
EMB_MODE?=skipgram
EMB_EPOCH?=10000
EMB_CORPUS?=voynich
EMB_NORMALIZE?=""

include mk/*.mk

.PHONY: embeddings

clean:
	rm -rf tmp corpora

.ONESHELL:
bin/fasttext:
	mkdir -p bin
	cd tmp
	wget https://github.com/facebookresearch/fastText/archive/v0.9.1.zip
	unzip v0.9.1.zip
	cd fastText-0.9.1
	make
	mv fasttext ../bin/


embeddings: bin/fasttext
	mkdir -p embeddings
	./bin/fasttext ${EMB_MODE} \
	               -input corpora/${EMB_CORPUS}.txt \
	               -output embeddings/${EMB_CORPUS}_${EMB_MODE}_${EMB_DIM} \
	               -dim ${EMB_DIM} \
	               -epoch ${EMB_EPOCH}

muse:
	python thirdparty/MUSE/unsupervised.py --src_lang en \
	                                       --tgt_lang vy \
	                                       --src_emb embeddings/herbs_${EMB_MODE}_${EMB_DIM}.vec \
	                                       --tgt_emb embeddings/voynich_${EMB_MODE}_${EMB_DIM}.vec \
	                                       --emb_dim ${EMB_DIM} \
	                                       --dis_most_frequent 3000 \
	                                       --exp_path experiments \
	                                       --exp_name herbs_voynich_${EMB_MODE}_${EMB_DIM} \
	                                        --n_refinement 100 \
	                                       --n_epochs 10 \
	                                       --batch_size 32 \
	                                       --normalize_embeddings ${EMB_NORMALIZE}
