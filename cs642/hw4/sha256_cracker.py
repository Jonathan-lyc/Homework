import os
import subprocess as sub
from multiprocessing import Pool, Process, Queue

#username = 'username'
#salt = '999999'
#given_hash = '873b8b6a77af4bb6cee4cae09eaa81b27556c7cd9786e754a169114b6d3674d5'
#start_val = 12344
username = 'ristenpart'
salt = '134153169'
given_hash = '37448ba7de7f5b4396697edaeddcd7bc840964e6ce82016915b830a91d69eb2f'
start_val = 140000

def crack(password=None):
    print "Trying: ", password
    p = sub.Popen("""perl -e 'use Digest::SHA qw(sha256_hex); print sha256_hex("{0},{1},{2}");'""".format(username, password, salt),stdout=sub.PIPE,stderr=sub.PIPE, shell=True)
    output, errors = p.communicate()
    if output == given_hash:
        print "Found password: {0}".format(password)
    return output

if __name__ == '__main__':
    # Set up multiprocessing
    #global queue
    #pool = Pool(7)
    #for g in range(0,100000):
        #queue.put(g)
    #p = Process(target=crack, args=None)
    #p.start()
    #p.join()

    i = start_val
    guess = crack(i)
    while guess != given_hash:
        guess = crack(i)
        #if guess[0] == '3':
            #print guess
        # Print every 10
        #if i % 10 == 0:
            #print i
        i += 1
        
    print guess