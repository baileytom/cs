#
# SERVER
#

# Import extravaganza
import socket
import threading
import sys
import time
import os
import math
import random

# Collect the port from the user.
while True:
    try:
        port = int(input("Enter the port number: "))
        break
    except:
        print("Invalid input")
#port = 1234

# Define global variables
acks = set()
packets = dict()
sequence_num = 0
low = 0
window_size = 5
lose_mode = False

losts = list()

# Create & bind UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_address = ('localhost', port)
print('Starting up on {} port {}'.format(*server_address))
sock.bind(server_address)

# Function to simulate packet loss
def did_lose():
    if not lose_mode:
        return False
    lost = random.random() < 0.1
    if lost:
        print("lost packet")
    return lost

def are_we_done(packet_num, address):
    are_we = True
    for i in range(packet_num):
        if i not in acks:
            are_we = False
            send_packet(packets[i], address)
    return are_we

# Method to send a packet with data
def send_packet(data, address):
    if not did_lose():
        sent = sock.sendto(data, address)
        print('Sent {} bytes to {}'.format(sent, address))
    else:
        losts.append(data)
        
# Method containing the loop that sends packets
def send_loop(filename, filesize):    
    global sequence_num
    global low
    global window_size
    with open(filename, "rb") as f:
        buf = None
        # While we are not at the end of the file
        getout = False
        while buf != bytearray() or len(acks) < filesize:
            if getout: break
            print("{}, {}".format(len(acks), filesize))
            send_attempts = 0
            while (sequence_num >= low + window_size):
                # check if we have acknowledgements
                while (low in acks):
                   low += 1
                
                # try to send it again
                if (send_attempts >= 2):
                    send_packet(packets[low], address)
                
                # we need to wait for acknowledgement
                if (send_attempts >= 10):
                    print("Attempt timeout.")
                    getout = True
                    break
                print("Waiting for acknowledgements... {}".format(low))
                time.sleep(0.5)
                send_attempts += 1
            else:
                # Read 1024 bytes
                buf = f.read(1024)
                # Set up the header
                header = str(sequence_num).zfill(16).encode()
                # Send the header + data to the address
                data = header + buf
                packets[sequence_num] = data
                
                # send it!
                send_packet(data, address)

                # Increment the sequence

                sequence_num += 1
        tries = 0
        while (not are_we_done(filesize, address) and tries < 10):
            tries += 1
        # send end flag
        #sent = sock.sendto(b'1010101010101011', address)

# Returns the data if it recieved a packet within a time frame
# If not, return false
def timeout_listen(seconds):
    sock.settimeout(seconds)
    try:
        message, address = sock.recvfrom(1040)
        return message
    except socket.timeout:
        print("Timed out.")
        return False

# Listen. Returns true if it got something within a time range.
# Returns fal
def listen():
    global sequence_num
    global low
    global window_size
    while True:
        sock.settimeout(None)
        data, address = sock.recvfrom(4096)
        try:
            print('Received {} bytes from {}'.format(len(data), address))
            acked_num = data[16:]
            if int(acked_num) == low:
                print("Incrementing window...")
                low += 1
            if acked_num != b'':
                acks.add(int(acked_num.decode()))
        except:
            continue
            
        # determine what the packet we recieved is. filename or acknowledgement.. ack comes with a header of 1000101 in binary

def send_packet_num(packet_num, address):
    header = "packet_num: ".encode()
    print("Sending packet num...")
    attempts = 0
    sock.settimeout(5)
    while attempts < 5:
        sent = send_packet(header + str(packet_num).encode(), address)
        try:
            data, server = sock.recvfrom(4096)
            if data == b'Got it':
                return
        except:
            print("No response. Trying again.")
            attempts += 1
    print("Client timed out.")
    sys.exit(1)
        
# Begin main loop
while True:
    sock.settimeout(None)
    print('\nWaiting for connection...')
    data, address = sock.recvfrom(4096)
    # If the incoming message is the endflag? Or whatever that is
    if data[:16] == b'0000000001000101':
        continue

    print(data)

    filename = data.decode()[8:]
    
    # We have to send the file size back so to do that we need the file size
    filesize = os.stat(filename).st_size
    packet_num = math.ceil(filesize/1024)
    
    send_packet_num(packet_num, address)

    if data:
        #thread start listening for acks here
        t1 = threading.Thread(target=listen)
        t1.start()
        send_loop(filename, packet_num)
    print("Done.")
    for i in losts:
        print(i)
    os.execl(sys.executable, sys.executable, *sys.argv)
    print(acks)
    acks = set()
    packets = dict()
    low = 0
    sequence_num = 0
        

