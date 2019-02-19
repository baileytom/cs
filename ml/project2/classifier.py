import math

# Naive bayesian classifier
class DocumentClassifier(object):
    vocab = []
    class_info = {}
    
    def __init__(self, training_file):
        raw_data = [l.split() for l in open(training_file, 'r').readlines()]
        # Concat documents into self.class_info[c][text]
        for i in raw_data:
            c, doc = i[0], i[1::]
            
            # Do operations on the doc, only look at word with > 3 length
            doc = [w for w in doc if len(w) > 3]
            
            if c not in self.class_info:
                self.class_info[c] = {'text': [],
                                      'n': 0,
                                      'words': {}}
            self.class_info[c]['text'] += doc
            self.class_info[c]['n'] += 1
        # Populate vocab
        for c in self.class_info.keys():
            self.vocab += self.class_info[c]['text']
        self.vocab = set(self.vocab)
        # Perform probability calculations for each class
        for c in self.class_info.keys():
            self.class_info[c]['prob'] = self.class_info[c]['n'] / len(raw_data)
            for word in self.class_info[c]['text']:
                try:
                    self.class_info[c]['words'][word]['count'] += 1
                except:
                    self.class_info[c]['words'][word] = {'count': 1,
                                                         'prob': 0}
            for word in set(self.class_info[c]['text']):
                self.class_info[c]['words'][word]['prob'] = \
                    (self.class_info[c]['words'][word]['count'] + 1) / \
                    (len(self.class_info[c]['text']) + \
                     len(self.vocab))
                
    # Get the class probability for class c
    def get_class_prob(self, c):
        return self.class_info[c]['prob']

    # Get the probability of a word given class c
    def get_word_prob(self, c, word):
        try:
            return self.class_info[c]['words'][word]['prob']
        except:
            return 1 / (len(self.class_info[c]['text']) + len(self.vocab))

    # Get the product of the class prob & each word prob
    def get_log_probability_of_class(self, c, doc):
        class_prob = math.log(self.get_class_prob(c))
        product = 0
        for word in doc:
            product += math.log(self.get_word_prob(c, word))
        return class_prob + product

    # Get the class with the maximum probability
    def classify(self, doc):
        best_c = None
        prob_prediction = None
        for c in self.class_info.keys():
            log_prob = self.get_log_probability_of_class(c, doc)
            if best_c is None or log_prob > prob_prediction:
                prob_prediction, best_c = log_prob, c
        return best_c

# Test the classifier
DC = DocumentClassifier('forumTraining.data')
test_data = [l.split() for l in open('forumTest.data', 'r').readlines()]
right, total = 0, 0
for line in test_data:
    c = line[0]
    doc = line[1::]
    prediction = DC.classify(doc)
    if prediction == c:
        right += 1
    total += 1
print(right/total)
