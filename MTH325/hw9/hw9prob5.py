import networkx as nx
import matplotlib.pyplot as plt

# problem 5 a

G = nx.Graph()

nodes = [i for i in 'ABCDEFG']
edges = [
    ('A', 'C', 4),
    ('C', 'D', 8),
    ('D', 'E', 2),
    ('E', 'G', 3),
    ('F', 'G', 3),
    ('D', 'B', 9)
]

def reset(d=False):
    global G
    G.clear()
    G.add_nodes_from(nodes, distance='∞', parent='n/a')
    G.add_weighted_edges_from(edges)
reset()
    
pos = nx.spring_layout(G,scale=2.0,dim=2,k=1,iterations=200)


def draw_state(G, f, t, d=False):
    global pos
    pos = nx.spring_layout(G,scale=2.0,dim=2,k=1,iterations=200)
    print(G.nodes.data())
    plt.figure(figsize=(7,7))
    e_labels = nx.get_edge_attributes(G, 'weight')
    n_labels = {k: "{}\n{},{}".format(k, str(v['distance']), v['parent']) for k,v in G.nodes.data()}
    nx.draw_networkx_nodes(G, pos, node_size=2000)
    nx.draw_networkx_edges(G, pos)
    if d:
        nx.draw_networkx_labels(G, pos, labels = n_labels)
    else:
        nx.draw_networkx_labels(G, pos)
    nx.draw_networkx_edge_labels(G, pos, edge_labels=e_labels)
    plt.axis('off')
    plt.title(t)
    plt.savefig(f)
    plt.gcf().clear()

# 5a

draw_state(G, '5a', 'total weight: 29', 0)

# 5b

fedges = [
    ('A', 'C', 4),
    ('A', 'D', 10),
    ('A', 'B', 9),
    ('D', 'F', 6),
    ('D', 'G', 4),
    #('C', 'D', 8),
    ('D', 'E', 2)
    #('E', 'G', 3),
    #('F', 'G', 3),
    #('D', 'B', 9)
]
G.clear()
G.add_weighted_edges_from(fedges)
G.add_node('A', distance=0, parent='n/a')
G.add_node('B', distance=9, parent='A')
G.add_node('D', distance=10, parent='A')
G.add_node('C', distance=4, parent='A')
G.add_node('E', distance=12, parent='D')
G.add_node('G', distance=14, parent='D')
G.add_node('F', distance=16, parent='D')

draw_state(G, '5b', 'total weight: 35', 1)
