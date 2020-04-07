# Attempting Voynich manuscript due to COVID-19-induced boredom

At the moment methods based on unsupervised machine translation are being implemented.
Roughtly speaking, the idea is to train monolingual word embeddings (their optimal dimensionality
[can be estimated](http://papers.nips.cc/paper/7368-on-the-dimensionality-of-word-embedding)) and
learn a mapping from the space of Voynich embeddings to the space of English embeddings
[using adversarial training and iterative Procrustes refinement](https://arxiv.org/abs/1711.00043).

## Preprocessing

Transcriptions are being preprocessed in the following manner:

- locus indicators and comments are stripped, since we are interested in main-text only,
- text is tokenized using both certain and uncertain word separators,
- it is assumed line breaks indicate splitted tokens discontinuation,
- high ascii entities are converted to corresponding characters,
- text is segmented into paragraphs (treated as sentences from the point of view of
  embeddings training algorithms),
- character-level n-gram word model is trained on top of certain transliterations
  and used to disambiguate alternative reading (whenever annotator marked his
  doubts we are choosing the most probable variant on the basis of Voynich word model).
