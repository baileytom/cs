from socket import AF_INET, socket, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR
from threading import Thread, enumerate
from sys import exit, argv

# This program is a client and server for lab 6. Run with argument 1 to act as a server
# and 0 to act as a client.
if len(argv) != 2:
    print("Usage: python cliserv.py [1 if server, 0 if client]")
    exit(1)

# This function handles the seperate threads for listening for/sending messages between
# the client and server. Argument 'listen' is a boolean to whether or not this thread
# is for listening.
def dialogue(other,listen):
    global done
    while not done:
        msg = other.recv(1024) if listen else bytes(input(), "utf-8")
        if msg.decode("utf8").lower() == "quit":
            if not done: print("Someone quit.")
            other.send(msg)
            done = True
        else: print("other: " + msg.decode("utf8")) if listen else other.send(msg)

# Collect necessary information to create the socket, and either bind or connect
# the socket.
serv, done, addr, sock = int(argv[1]), 0, ("localhost" if int(argv[1]) else input("IP: "), int(input("Port: "))), socket(AF_INET, SOCK_STREAM)
sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
sock.bind(addr) if serv else sock.connect(addr)

# If we are a server, wait for a connection from the client.
if serv:
    sock.listen(5)
    print("Waiting for connection...")
    client, caddr = sock.accept()
    print("New connection from {}".format(caddr))
    client.send(bytes("You are connected.", "utf8"))
# Open two threads, one for listening, one for sending.
for x in [0,1]: Thread(target=dialogue, args=(client if serv else sock, x)).start()
