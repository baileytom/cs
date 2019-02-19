import math
# please excuse my ugly code

# load in the training data

# this is a list of documents (list of words)
# so its a 2d list
training_lines = [l.split() for l in open('forumTraining.data', 'r').readlines()]

# processing
vocab = []
training_dict = {}
num_docs = 0
for i in training_lines:
    c, doc = i[0], i[1::]
    num_docs += 1
    # add to vocab
    vocab += doc

    # put doc in training dict
    if c not in training_dict:
        training_dict[c] = []
    training_dict[c].append(doc)
    
# make vocab items unique
vocab = set(vocab)

# processing
cprob = {}
texts = {}
for c, docs in training_dict.items():
    
    cprob[c] = len(docs) / num_docs
    texts[c] = []
    for doc in docs:
        for word in doc:
            texts[c].append(word)
    #texts[c] = [j for j in i for i in docs]
    
# for each word w_k in vocabulary, n_k is the number of time w_k occurs in text
# estimate of word occurance for particular doc type:
#  p(w_k | c_j) = (n_k + 1) / (n + |vocabulary|)

# precalculate some stuff
wcount = {c: {} for c in training_dict.keys()}
wprob = {c: {} for c in training_dict.keys()}
for c in training_dict.keys():
    for word in texts[c]:
        if word not in wcount[c]:
            wcount[c][word] = 0
        wcount[c][word] += 1

for c in training_dict.keys():
    for word, count in wcount[c].items():
        wprob[c][word] = (count + 1) / (len(texts[c]) + len(vocab))
        #print(wprob[c][word], c, word)
        #input()

def word_prob(word, c):
    if word not in wprob[c]:
        return 1 / (len(texts[c]) + len(vocab))
    return wprob[c][word]
        
def get_prob_of(doc, c):
    pc = cprob[c]
    wproduct = 1
    for word in doc:
        wproduct += math.log(word_prob(word, c))
    return math.log(pc) + wproduct

def classify(doc):
    predicted_c = None
    prob_prediction = -99999
    for c in training_dict.keys():
        calc_prob = get_prob_of(doc, c)
        
        if calc_prob > prob_prediction:
            prob_prediction = calc_prob
            predicted_c = c
    return predicted_c

test_lines = [l.split() for l in open('forumTest.data', 'r').readlines()]


right = 0
total = 0

what = {}

for line in test_lines:
    c = line[0]
    doc = line[1::]
    
    classified = classify(doc)
    
    if classified not in what:
        what[classified] = 0
    what[classified] += 1
    
    if classified == c:
        right += 1
    total += 1

print(right/total)

print(what)
