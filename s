#!/usr/bin/python

import socket
import optparse
import time
import sys

def transmit_throughput(host,port,size): 
    print "Transmit Throughput Test"
    data = '*' * 1024
    data_len = 0 
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 

    try:
        s.connect((host,port)) 
    except socket.error, msg: 
        print 'ERROR: ',msg 
        s.close() 
        s = None 

    if s is None: 
        sys.exit(1) 

    print "Sending: %d bytes to %s:%d"%(size*1024, host, port)
    t1 = time.time() 
    for n in range(size): 
        s.send(data) 
        data_len += len(data) 
    t2 = time.time() 
    tx_time = t2 - t1 
    print "Bytes Sent: %d in %f seconds (%f Mbits/s)"%(data_len, tx_time, data_len / tx_time * 8 / 1024 / 1024.0) 
    print "Closing Connection"
    s.close()


def receive_throughput(host, port): 
    print "Receive Throughput Test"
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) 
    s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1) 
    try:
        s.bind((host, port)) 
        s.listen(1)
    except socket.error, msg: 
        print "ERROR: ", msg
        s.close()
        s = None

    if s is None:
        sys.exit(1)

    while 1:
        print "Listening on: %s:%d"%(host, port)
        data_len = 0
        try:
            conn, addr = s.accept() 
        except KeyboardInterrupt: 
            print "Closing Connection"
            s.close()
            s = None
            sys.exit(1)

        print 'Connected accepted: ', addr 
        t1 = time.time() 
        while 1:
            data = conn.recv(4096) 
            if not data: break
            data_len += len(data) 
        t2 = time.time()
        rx_time = t2 - t1
        print "Bytes Received: %d in %f seconds (%f Mbits/s)"%(data_len, rx_time, data_len / rx_time * 8 / 1024 / 1024.0)
        conn.close()

if __name__ == '__main__': 
    parser = optparse.OptionParser()
    parser.add_option("-p", "--port", dest="port", type="int", default=50008, help="Port to listen on or transmit to [default: %default].")
    parser.add_option("--hostname", dest="hostname", default="", help="Hostname to listen on or tansmit to.")
    parser.add_option("--transmit", dest="transmit", action="store_true", default=False, help="Perform a transmit throughput test [default: %default]")
    parser.add_option("--size", dest="size", type="int", default=100, help="Number of Kilobytes to transmit [default: %default Kbyte]")

    (options, args) = parser.parse_args()

    if options.transmit:
        transmit_throughput(options.hostname, options.port, options.size)
    else:
        receive_throughput(options.hostname, options.port)
