import sys
from subprocess import Popen, PIPE

if __name__ == '__main__':
    baseCiphertext = "14f4ad7c5dd5c1b013e6e1226a7d01d5310c4cd534f41f063e0230d2ccbd762c8652a2ba0d048ae81dcb66fc3e5db28872d2efdedb78d5b636b7f43d2d48c1922e6fc77f05f317be9ffd1a3d8bca755a"
    print "base", baseCiphertext
    #hexCiphertext = baseCiphertext[:20] + str(sys.argv[1]).encode("hex") + baseCiphertext[28:]
    for i in range(0,147):
        print "Testing ", i, i+16, len(baseCiphertext[i:i+16])
        #hexCiphertext = baseCiphertext[:i] + "0"*16 + baseCiphertext[i+16:]
        hexCiphertext = baseCiphertext[:15] +  baseCiphertext[i:i+16] + baseCiphertext[32:]
    #print "hex ", hexCiphertext
        proc = Popen(["./baddecrypt.py",hexCiphertext],stdout=PIPE)
        output = proc.communicate()[0]
        print output

    
# If we switch things around...maybe it'll work.
# Instead of 000pass we could have pass000, maybe hmac will still authenticate.