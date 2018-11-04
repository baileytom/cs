import netifaces
import socket
import sys
import uuid
import struct
import binascii

MAC = uuid.getnode()
BROADCAST = '0xffffffffffffL'
ARP_TYPE = '\x08\x06'
ICMP_TYPE = '\x08\x00'

sock = socket.socket()
sockets = {}
icmp_sent = []
flag = True

def main():
    global sock
    global sockets
    

    # Get the names and addresses of the network interfaces as a list.
    interfaces = list(map(lambda i: [i, netifaces.ifaddresses(i)], netifaces.interfaces()))

    s = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(3))

    # Loop over the network interfaces
    for interface in interfaces:
        name = interface[0]
        addresses = interface[1]
        # Loop over the AF_INET addresses for each
        for address in addresses[netifaces.AF_INET]:
            print str.format("Interface: {}", name)
            # Create a packet socket on interface r?-eth1
            if True:
                print str.format("Creating socket on interface {}", name)
                print address.get("addr")
                try:
                    sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(0x003))
                    pass
                except:
                    print "Socket error."
                    sys.exit()
                sock.bind((name, 0))
                sockets[name] = sock

    while True:
        handle_packet(*s.recvfrom(1024))

def handle_packet(data, address):
    # Determine the type of packet
    if address[0] == 'lo':
        return

    ptype = struct.unpack("!6s6s2s", data[0:14])[2]

    # Very intuitive if else
    {ARP_TYPE:[ARP_forward,ARP],ICMP_TYPE:[ICMP_forward,ICMP]}[ptype][1](data, address)
    
# Utility
def mac2bin(mac):
    return binascii.unhexlify(mac.replace(':', ''))

# Utility
def getmacforip(ip):
    for i in netifaces.interfaces():
        if netifaces.ifaddresses(i)[2][0].get("addr") == ip:
            return netifaces.ifaddresses(i)[17][0].get("addr")
        
def ARP(data, address):
    eth_head = data[0:14]
    arp_head = data[14:42]

    eth_list = struct.unpack("!6s6s2s", eth_head)
    arp_list = struct.unpack("!2s2s1s1s2s6s4s6s4s", arp_head)

    if arp_list[4] == "\x00\x02":
        return
    
    source = socket.inet_ntoa(arp_list[6])
    destination = socket.inet_ntoa(arp_list[8])
    
    dest_MAC = getmacforip(destination)

    if dest_MAC is None:
        return

    out_eth_list = list(eth_list)
    out_arp_list = list(arp_list)

    out_arp_list[4] = "\x00\x02"

    # Swap source / destination addresses
    out_arp_list[6], out_arp_list[8]  = arp_list[8], arp_list[6]

    # Change destination MAC address
    out_eth_list[0], out_arp_list[7] = eth_list[1], arp_list[5]
    
    out_eth_list[1] = mac2bin(dest_MAC)
    out_arp_list[5] = mac2bin(dest_MAC)

    out_eth_head = struct.pack("!6s6s2s", *tuple(out_eth_list))
    out_arp_head = struct.pack("!2s2s1s1s2s6s4s6s4s", *tuple(out_arp_list))

    packet = out_eth_head + out_arp_head
        
    outsock = sockets[address[0]]

    print("ARP response\nEth + arp head: " + binascii.hexlify(out_eth_head + out_arp_head))

    outsock.sendto(out_eth_head + out_arp_head, address)

def ICMP(data, address):    
    global icmp_sent
    global flag

    eth_head = data[0:14]
    eth_list = struct.unpack("!6s6s2s", eth_head)
    
    ip_head = data[14:34]
    ip_list = struct.unpack("1s1s2s2s2s1s1s2s4s4s", ip_head)

    icmp_head = data[34:42]
    icmp_list = struct.unpack("1s1s2s4s", icmp_head)

    out_eth_list = list(eth_list)
    out_ip_list = list(ip_list)
    out_icmp_list = list(icmp_list)

    # Swap source / destination addresses
    out_ip_list[8], out_ip_list[9] = ip_list[9], ip_list[8]

    # Change destination MAC address
    out_eth_list[0], out_eth_list[1] = eth_list[1], eth_list[0]

    out_icmp_list[0] = '\x00'

    out_eth_head = struct.pack("6s6s2s", *tuple(out_eth_list))
    out_ip_head = struct.pack("1s1s2s2s2s1s1s2s4s4s", *tuple(out_ip_list))
    out_icmp_head = struct.pack("1s1s2s4s", *tuple(out_icmp_list))

    head = out_eth_head + out_ip_head + out_icmp_head
    packet = head + data[42:]

    if address[0] == 'lo':
        return

    if packet not in icmp_sent and flag:
        icmp_sent.append(packet)
        print "ICMP response\n Eth + ip + icmp head: {}".format(binascii.hexlify(head))
        sock.sendto(packet, address)
    else:
        pass
    flag = not flag

def ARP_forward(data, address):
    print "ARP FORWARD"

def ICMP_forward(data, address):
    print "ICMP FORWARD"

main()
