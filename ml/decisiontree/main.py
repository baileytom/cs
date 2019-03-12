import math

categories = []
attributes = {}
examples = []

# Return the cleaned lines from the file
def read_data(filename):
    file = open(filename, 'r')
    lines = file.readlines()
    lines = [l.strip() for l in lines]
    return lines

# Return the data like this: [C, A, E],
# where C is the list of classes,
# A is a dict of attributes to the list of their possible values,
# and E is a 2d list of examples
def process_data(data):
    global categories
    global attributes
    global examples
    categories = data[1].split(',')
    attributes = {l.split(',')[0]: l.split(',')[2:] for l in data[3:3+int(data[2])]}
    examples = [l.split(',') for l in data[4+int(data[2]):]]
    return [categories, attributes, examples]

# Return -sum from i=1 to k of p_i * log2(p_i)
def get_entropy(S):
    k = categories
    msum = 0
    for i in k:
        # Calculate p_i = N_i (cardinality of i) / N (cardinality of S)
        N_i = len(list(filter(lambda x: x[-1] == i, S)))
        N = len(S)
        try:
            p_i = N_i / N
        except:
            pass
        try:
            msum += p_i * math.log(p_i, 2)
        except:
            pass
    return -msum

# Do gain calculation
def get_gain(attribute, S):
    a_pos = list(attributes.keys()).index(attribute)
    msum = 0
    for value in attributes[attribute]:
        S_v = list(filter(lambda x: x[a_pos] == value, S))
        msum += len(S_v) / len(S) * get_entropy(S_v)
    return get_entropy(S) - msum

class Node(object):
    def __init__(self, result=None):
        self.attribute = None
        self.children = {}
        self.result = result

def recur(node_attributes, node_examples):
    # continue recursively, until each attribute appears once on a path,
    # or until a leaf node is created.
    # how do we know if it is a leaf node? if the examples 'sorted' down the
    # tree have the same class
    
    # if all examples in S are of the same class
    all_the_same = True
    for example in node_examples:
        if example[-1] != node_examples[0][-1]:
            all_the_same = False
    if all_the_same:
        # return a leaf with that class label
        return Node(node_examples[0][-1])

    # else if there are no more attributes to test
    if len(node_attributes) == 0:
        counter = {}
        for example in node_examples:
            if example[-1] in counter:
                counter[example[-1]] += 1
            else:
                counter[example[-1]] = 1
        counted = sorted(counter, key=counter.get, reverse=True)
        # return a leaf with the most common class label
        return Node(counted[0])

    # otherside choose the attribute a that maximizes the information gain of S
    max, best = -1, None
    for a in node_attributes:
        gain = get_gain(a, node_examples)
        if gain > max:
            max = gain
            best = a
    # let attribute a be the decision for the current node
    a = best
    a_pos = list(attributes.keys()).index(best)
    next_attributes = [a for a in node_attributes if a != best]
    node = Node()
    node.attribute = best
    # add a branch from the current node for each possible value of a
    for value in attributes[a]:
        # sort examples that match this value of attribute a
        S_v = list(filter(lambda x: x[a_pos] == value, node_examples))
        # recursively call ID3(Sv) on the set of examples in each branch
        if S_v == []:
            continue
        node.children[value] = recur(next_attributes, S_v)
    return node

def traverse(node, indent=""):
    if node.result is not None:
        print(indent + node.result)
        return
    print(indent + node.attribute)
    for child in node.children:
        print(indent + child)
        traverse(node.children[child], indent+"_")
        
def make_decision_tree(filename):
    process_data(read_data(filename))
    root = recur(list(attributes.keys()), examples)
    #traverse(root)
    return root

def classify(node, example):
    if node.result:
        return node.result
    a_pos = list(attributes.keys()).index(node.attribute)
    return classify(node.children[example[a_pos]], example)
    
root = make_decision_tree("fishing.data")
    
example1 = ["Strong", "Warm", "Cold", "Sunny"]
example2 = ["Weak", "Cold", "Warm", "Rainy"]

print(classify(root, example2))
