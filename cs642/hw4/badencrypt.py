#!/usr/bin/python
# CS 642 University of Wisconsin
#
# WARNING:
# Do not use this encryption functionality, it has security vulnerabilities!
#
# Your job is to find and understand the problems
#

import sys
import os
import Crypto.Cipher.AES
#from Crypto.Random import get_random_bytes
import hmac
import hashlib
import base64
import struct

f = open( 'keyfile', 'r')
key1 = f.readline()
key1 = key1[:32].decode("hex")
key2 = f.readline()
key2 = key2[:32].decode("hex")
f.close()

# Grab plaintext from first argument
message = sys.argv[1]
print "Message: ", message
print "Encoded Message: ", str(message).encode("hex")
# Format is header + message + tag + padding
# where:
# header has
#   version number (1 byte)
#   subversion number (1 byte)
#   reserved zero byte (1 byte)
#   reserved zero byte (1 byte)
#   arbitrary padding (8 bytes)s
#   plaintext length as an unsigned int (4 bytes)
# padding is just 0 bytes
# and the tag is HMAC-SHA256 computed over the header and message
a = struct.pack( '<BBBBIII', 1, 1, 0, 0, 0, 0, len(message) ) + 'A'
#print "Struct: ", a + message
plaintext = struct.pack( '<BBBBIII', 1, 1, 0, 0, 0, 0, len(message) ) + message 
print "Plaintext: ", plaintext
print "Encoded Plaintext: ", str(plaintext).encode("hex")

tag = hmac.new(key2, plaintext, hashlib.sha256).digest()
print "Tag: ", str(tag).encode("hex")

plaintext += tag 
if len(plaintext) % 16: 
    padlen = 16 - (len(plaintext) % 16)
    plaintext += '0' * padlen

iv = os.urandom(16)
print "IV: ", str(iv).encode("hex")
print "Padded Plaintext: ", str(plaintext).encode("hex")


cipher = Crypto.Cipher.AES.new(key1, Crypto.Cipher.AES.MODE_CBC, IV=iv )
print "iv len: {0}, plaintext len: {1}".format(len(iv), len(plaintext))
print (str(iv) + cipher.encrypt( plaintext )).encode("hex")

