"""
Preprocess given file assuming it is in Eva format.
See: http://www.voynich.nu/transcr.html
"""

import re
import sys

from nltk.lm import MLE
from nltk.util import ngrams


def clear(text):
    """
    Removes unnecessary annotations.
    """
    for single in ('<$>',      # End of paragraph
                   '/',        # End of line
                   '{', '}',   # Ligature of standard characters
                   '<->',      # Drawing intrusion
                   '\''):      # '
        text = text.replace(single, '')

    text = re.sub(r'<![^>]+>', '', text)  # Comment

    return text


def high_ascii(text):
    """
    Convert high ASCII to characters.
    """
    return re.sub(r'@(\d{3});', lambda m: chr(int(m.group(1))), text)


def unigrams(word):
    """
    Splits word into characters and ads special tokens
    indicating beginning and end of sequence.
    """
    return ['<W>'] + list(word) + ['</W>']


def build_word_model(corpus, order=3):
    """
    Creates character-level n-gram word model.
    """

    def ngramize(w, order):
        l = []
        for o in range(1, order + 1):
            l.extend(ngrams(w, o))
        return l

    words = ' '.join(corpus).split()  # Flatten corpus into words
    words = [w for w in words if re.match(r'[a-z]', w)]  # Use clean words only

    vocab = set()
    data = []

    for word in words:
        w = unigrams(word)
        vocab.update(w)
        data.append(ngramize(w, order))

    model = MLE(order)
    model.fit(data, vocabulary_text=vocab)

    return model


def solve_uncertain_reading(text, model):
    """
    Brackets are used to provide alternative reading.
    We are choosing the most probable variant
    on the basis of character-level word model.
    """

    def solve(alternative):
        prefix, options, suffix = alternative.groups()
        options = options.split(':') if ':' in options else list(options)
        options = sorted(options, key=lambda o: model.perplexity(prefix + o + suffix))
        return prefix + options[0] + suffix

    return re.sub('(\w*)\[(.*?)\](\w*)', solve, text)


def tokenize(text):
    """
    Splitting by both certain and uncertain word separators.
    """
    return re.sub(r'[,\.]', ' ', text)


def segment(text):
    """
    Segment into paragraphs.
    """
    return [t for t in text.split('<%>') if t]


def final_touch(text):
    """
    Remove redundant spaces.
    """
    return re.sub(r'\s\s+', ' ', text)


def preprocess(filename):
    """
    Preprocess given filename assuming it is in Eva alphabet.
    """
    with open(filename) as ins:
        # Extract text (strip locus indicators)
        text = []
        for line in ins:
            if line[0] == '#':
                continue
            line = re.sub(r'^<.*?>\s+', '', line.rstrip())
            text.append(line)

        # Merge lines
        text = clear('.'.join(text))

        # Convert high ascii entities to characters
        text = high_ascii(text)

        # Tokenize and segment into paragraphs
        corpus = [tokenize(paragraph) for paragraph in segment(text)]

        # Build char-level n-gram word model...
        model = build_word_model(corpus)
        for paragraph in corpus:

            # ...and use it to provide the most probable reading
            # in case of uncertain transliterations
            paragraph = solve_uncertain_reading(paragraph, model)

            # Clear duplicated spaces
            print(final_touch(paragraph))

if __name__ == '__main__':
    if len(sys.argv) == 2:
        preprocess(sys.argv[1])
    else:
        print (f'Syntax: ./{sys.argv[0]} [input filename]')
