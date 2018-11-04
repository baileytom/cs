# CLIENT

import socket
import sys
import random

# Create a UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True:
    try:
        port = int(input("Port number: "))
        break
    except:
        print("Invalid input")

while True:
    try:
        ip = input("IP address: ")
        break
    except:
        print("Invalid input")

loss_mode = False

def send_packet(data, address):
    lost = random.random()
    if lost > 0.1 or not loss_mode:
        return sock.sendto(data, address)
    else:
        print('packet was lost')
    return None

def acknowledge_packet(packet_num, address):
    print("Acking packet {}".format(packet_num))
    header = str(1000101).zfill(16).encode()
    send_packet(header + packet_num, address)

# Send the filename, retrun the number of packets
def get_packet_num(filename, address):
    header = str(69201).zfill(8).encode()
    print("Sending filename...")
    encoded_filename = str.encode(filename)
    attempts = 0
    sock.settimeout(5)
    while attempts < 5:
        sent = send_packet(header + encoded_filename, address)
        try:
            data, server = sock.recvfrom(4096)
            print("Packet number received.")
            return int(data.decode()[12:])
        except socket.timeout:
            print("No response. Trying again.")
            attempts += 1
    print("Server timed out.")
    sys.exit(1)

# Acknowledge the packet number, return the body of the first packet
def acknowledge_packet_num(address):
    print("Acknowledging packet number...")
    message = b'Got it'
    attempts = 0
    sock.settimeout(5)
    while attempts < 5:
        sent = send_packet(message, address)
        try:
            data, server = sock.recvfrom(4096)
            print("First packet received.")
            return data[16:]
        except socket.timeout:
            print("No response. Trying again.")
            attempts += 1
    print("Server timed out.")
    sys.exit(1)

    
#port = 1234
#ip = "127.0.0.1"

server_address = (ip, port)

# Dict to hold the packets before we write them
packets = dict()

filename = (input("Enter the filename: "))

low = 0
sequence_num = 0
window_size = 5

packets_written = 0

try:

    # Get the number of packets for the file
    packet_num = get_packet_num(filename, server_address)

    print(packet_num)
    
    # Open the write file
    with open('rec' + filename, 'w+b') as f:
        # Acknowledge packet number, get the first packet
        packets[0] = acknowledge_packet_num(server_address)
        while packets_written < packet_num:
            data, server = sock.recvfrom(4096)
            
            sequence_num = data[:16]
            body = data[16:]
            
            packets[int(sequence_num)] = body
            
            while low in packets:
                print("Writing packet {}".format(low))
                f.write(packets[low])
                packets_written += 1
                low += 1

            acknowledge_packet(sequence_num, server_address)

finally:
    print('Done.')
