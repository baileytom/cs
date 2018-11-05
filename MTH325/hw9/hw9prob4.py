import networkx as nx
import matplotlib.pyplot as plt

# problem 4 a

G = nx.Graph()

nodes = [i for i in 'ABCDEFG']
edges = [
    ('F', 'E', 5),
    ('F', 'G', 5),
    ('G', 'E', 15),
    ('E', 'D', 30),
    ('D', 'B', 5),
    ('D', 'A', 5),
    ('D', 'C', 10),
    ('B', 'A', 15),
    ('C', 'A', 20)
]

def reset():
    global G
    G.add_nodes_from(nodes, distance='∞', parent='n/a')
    G.add_weighted_edges_from(edges)
reset()
    
pos = nx.spring_layout(G,scale=2.0,dim=2,k=1,iterations=200)


def draw_state(G, f, t):
    plt.figure(figsize=(7,7))
    e_labels = nx.get_edge_attributes(G, 'weight')
    n_labels = {k: "{}\n{},{}".format(k, str(v['distance']), v['parent']) for k,v in G.nodes.data()}
    nx.draw_networkx_nodes(G, pos, node_size=2000)
    nx.draw_networkx_edges(G, pos)
    nx.draw_networkx_labels(G, pos, labels = n_labels)
    nx.draw_networkx_edge_labels(G, pos, edge_labels=e_labels)
    plt.axis('off')
    plt.title(t)
    plt.savefig(f)
    plt.gcf().clear()

# set up root
G.add_node('A', distance=0, parent='n/a')
draw_state(G, '4a0', 'initial state')

# step 1
G.add_node('A', distance=0, parent='n/a')
G.add_node('B', distance=15, parent='A')
G.add_node('C', distance=20, parent='A')
G.add_node('D', distance=5, parent='A')
draw_state(G, '4a1', 'token on A')

# step 2, D
G.add_node('B', distance=10, parent='D')
G.add_node('C', distance=15, parent='D')
G.add_node('E', distance=35, parent='D')
draw_state(G, '4a2', 'token on D')


# step 2.5, B & C
draw_state(G, '4a3', 'token on B')
draw_state(G, '4a4', 'token on C')



# step 3, E
G.add_node('F', distance=40, parent='E')
G.add_node('G', distance=50, parent='E')
draw_state(G, '4a5', 'token on E')


# step 4, F
G.add_node('G', distance='45', parent='F')
draw_state(G, '4a6', 'token on F')
draw_state(G, '4a7', 'token on G')

# problem 4 b
G.remove_edge('E', 'G')
G.remove_edge('A', 'C')
G.remove_edge('A', 'B')
draw_state(G, '4b', 'spanning tree')

#problem 4 c
reset()
G.remove_edge('D', 'E')
G.add_node('A', distance=0, parent='n/a')
G.add_node('D', distance=5, parent='A')
G.add_node('B', distance=10, parent='D')
G.add_node('C', distance=15, parent='D')
draw_state(G, '4c', '')

