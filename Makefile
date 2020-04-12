EMB_DIM?=10
EMB_MODE?=skipgram
EMB_EPOCH?=10000
EMB_CORPUS?=voynich
EMB_THREAD?=12
EMB_DICT_LIMIT?=20000

EMB_NORMALIZE?=""
MAP_OPTIMIZER?="sgd,lr=0.1"
ADVERSARIAL?=True
TGT_EMB?=herbs


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
	               -thread ${EMB_THREAD} \
	               -epoch ${EMB_EPOCH}
	sed -i '${EMB_DICT_LIMIT},$$ d' embeddings/${EMB_CORPUS}_${EMB_MODE}_${EMB_DIM}.vec

muse:
	PYTHONPATH=thirdparty/MUSE/ python muse.py --tgt_lang en \
	                                           --src_lang vy \
	                                           --tgt_emb embeddings/${TGT_EMB}_${EMB_MODE}_${EMB_DIM}.vec \
	                                           --src_emb embeddings/voynich_${EMB_MODE}_${EMB_DIM}.vec \
	                                           --emb_dim ${EMB_DIM} \
	                                           --dis_most_frequent 3410 \
	                                           --exp_path experiments \
	                                           --exp_name ${TGT_EMB}_voynich_${EMB_MODE}_${EMB_DIM} \
	                                           --n_refinement 5 \
	                                           --n_epochs 5 \
	                                           --batch_size 32 \
	                                           --normalize_embeddings ${EMB_NORMALIZE} \
	                                           --map_optimizer ${MAP_OPTIMIZER} \
	                                           --adversarial ${ADVERSARIAL} \
	                                           --epoch_size 100000 \
	                                           --max_vocab ${EMB_DICT_LIMIT}
