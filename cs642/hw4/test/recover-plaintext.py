#!/usr/bin/env python

import sys
from subprocess import Popen, PIPE

if __name__ == '__main__':
    input = sys.argv[1]
    #hexCiphertext = baseCiphertext[:20] + str(sys.argv[1]).encode("hex") + baseCiphertext[28:]
    for i in range(0,148):
        print "Testing ", i, i+16
        hexCiphertext = baseCiphertext[:16] + baseCiphertext[i:i+16] + baseCiphertext[32:]
    #print "hex ", hexCiphertext
        proc = Popen(["./baddecrypt.py",hexCiphertext],stdout=PIPE)
        output = proc.communicate()[0]
        print output

