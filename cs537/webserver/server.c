#include "cs537.h"
#include "request.h"
#include <string.h>
#include "shortcuts.h"
#define DEBUG (0)
#define D2 (1)
// 
// server.c: A very, very simple web server
//
// To run:
//  server <portnum (above 2000, below 65535)> <number of threads> <number of buffers> <scheduler> <epoch (for SFF-BS only)>
//
// Repeatedly handles HTTP requests sent to this port number.
// Most of the work is done within routines written in request.c
//

// CS537: Parse the new arguments too
pthread_mutex_t lock;
pthread_cond_t empty;
pthread_cond_t fill;
int schedalg;
int epoch; // Only used if scheduler is SFF-BS 
int currepoch; 
int buffersize = 0;
int maxbuffers;
request *buffer;


void usage(char *argv[]) {
    fprintf(stderr, "Usage: %s <port> <threads> <buffers> <scheduler>\n", argv[0]);
    exit(1);
}

void getargs(int *port, int *threads, int *buffers, int argc, char *argv[])
{
    if (argc < 5 || argc > 6) {
	  
	  usage(argv);
	}
    *port = atoi(argv[1]);
    if (*port > 65535 || *port < 2000) { 
        usage(argv);
	}
    *threads = atoi(argv[2]);
    if (*threads < 1) {
        usage(argv);
	}
    *buffers = atoi(argv[3]);
	maxbuffers = atoi(argv[3]);
    if (*buffers < 1) {
        usage(argv);
	}
    // FIFO = 0, SFF = 1, SFF-BS = 2
    
    if (strcmp(argv[4], "FIFO") == 0) {
        schedalg = 0;
		if (argc != 5) {
			usage(argv);
		}
	}
	else if (strcmp(argv[4], "SFF") == 0) {
	    schedalg = 1; 
		if (argc != 5) {
			usage(argv);
		}
		
	}
	else if (strcmp(argv[4], "SFF-BS") == 0) {
	    if (argc != 6) {
			usage(argv);
		}
		epoch = atoi(argv[5]);
		schedalg = 2; 
		
	}
	else {
	  usage(argv);
	}
}

// Queue put
// Returns 0 if worked, -1 if full
int put (int  fd) {
	request id; // wrap fd in request struct
	id.fd = fd;
	
	//Stat timings
	struct timeval tv;
	gettimeofday(&tv, NULL); 
	id.req_arrival = (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
	
	request stats = requestInit(id);
    
	if (buffersize >= maxbuffers) { // Buffer full!
		return -1;
	}
	
	if (schedalg < 3) {
		if (buffersize < maxbuffers) {
			buffer[buffersize] = stats;
			buffersize++;
			return 0;
		}
	}
	else {
	    printf("schedalg not within valid range of 0 - 2");
	    exit(3);
	}
	return -1;
}

// Queue get
// Return stats with size -1 if nothing left, else returns fd
request get() {
	// Time we start working on request
	struct timeval tv;
	gettimeofday(&tv, NULL);
    long int work = (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
	
	// Dummy request to check for failure
	request stats;
	stats.size = -1;
	// FIFO
	if (schedalg == 0) {
		// Nothing in buffer..FAIL!
	    if (buffersize == 0) {
			return stats;
	    }
	    else { // Should be stats=buffer[0]; then, shift everything down one. buffersize--;
			stats = buffer[0];

            // Shift all array elems down.
            int j;
            for (j = 0; j < buffersize - 1; j++) {
                buffer[j] = buffer[j + 1];
            }

			//Store time
			int long arrive = stats.req_arrival;
			stats.req_dispatch = work - arrive;

            buffersize--;
			return stats;
	    }
	}
	// Smallest File First
	else if (schedalg == 1 || buffersize < epoch) {
		int small = -1;
		request smallreq;
		int i;
		
		for ( i = 0; i < buffersize; i++) {//Find smallest
			if (small == -1) {
				small = i;
				smallreq = buffer[i];
			}
			else {
				request a = buffer[i];
				if (a.size < smallreq.size) {
					small = i;
					smallreq = buffer[i];
				}
			}
		}
		int j;
		for (j = small; j < buffersize - 1; j++) {
			buffer[j] = buffer[j + 1];
		}
		
		//Store time
		int long arrive = stats.req_arrival;
        smallreq.req_dispatch = work - arrive;
		
		buffersize--;
		return smallreq;
	}
	// Smallest File First with Bounded Starvation
	else if (schedalg == 2) {
		int small = -1;
		request smallreq;
		int i;
		if (currepoch == 0) {
			currepoch = epoch;
		}
		for ( i = 0; i < currepoch; i++) { //Find smallest in epoch
			if (small == -1) { //Initialize
				small = i;
				smallreq = buffer[i];
			}
			else {
				request a = buffer[i];
				if (a.size < smallreq.size) { //If smaller, save it
					small = i;
					smallreq = buffer[i];
				}
			}
		}
		currepoch--;
		
		int j;
		for (j = small; j < buffersize - 1; j++) {
			buffer[j] = buffer[j + 1];
		}
		
		//Store time
		int long arrive = stats.req_arrival;
        smallreq.req_dispatch = work - arrive;
		
		buffersize--;
		return smallreq;
	}
	else {
		printf("schedalg not within valid range of 0 - 2");
		exit(3);
	}
}

void consumer(int id) {
	// Assign id
	int thread_id = id;
	int thread_count = 0;
	int thread_static = 0;
	int thread_dynamic = 0;
	fprintf(stderr, "threadid: %d\n", id);
	while(1) {
		if (DEBUG) { fprintf(stderr, "consumer start\n"); }
		Mutex_lock(&lock);
		while(buffersize == 0){
			if (DEBUG) { fprintf(stderr, "consumer wait\n"); }
			Cond_wait(&fill, &lock);
            if (DEBUG) { fprintf(stderr, "consumer awake, buff: %d\n", buffersize); }
		}
		request stat = get();
        if (stat.size == -1) {
            Cond_wait(&fill, &lock);
			
		// Increment thread specific stats
        }
        if (stat.is_static == 0) {
            thread_dynamic++;
        }
        else {
            thread_static++;
        }
        thread_count++;
		// Set thread specific stats
		stat.thread_id = thread_id;
		stat.thread_count = thread_count;
		stat.thread_static = thread_static;
		stat.thread_dynamic = thread_dynamic;
		
		 //This could be moved outside the lock maybe? Might fix fifo test
		Cond_signal(&empty);
		requestHandle(stat);
        Mutex_unlock(&lock);
		
        

		if (DEBUG) { fprintf(stderr, "consumer end\n"); }
	}
}
int main(int argc, char *argv[])
{
    int listenfd, connfd, port, clientlen, threads, buffers;
    struct sockaddr_in clientaddr;

    getargs(&port, &threads, &buffers, argc, argv);
    
	//Buffers incoming connections
	buffer = (request *) malloc(buffers * sizeof(request)); 
	if (buffer == NULL) {
	  // Malloc failed, must be out of memory.
	  printf("Malloc failed");
	  exit(2);
	}
	
	// Initializations
	Mutex_init(&lock);
	Cond_init(&empty);
	Cond_init(&fill);
	
	// cid will be the container for threads
	pthread_t  cid[threads];
	
    // 
    // CS537: Create thread pool of consumers
    //
    /* Allocate memory for pthread_create() arguments */
    
	int i;
	for (i = 0; i < threads; i++) {
		Pthread_create(&cid[i], consumer, i);
	}
    listenfd = Open_listenfd(port);

    // Add in check for the conditional variables here.
	// This is the producer thread. it will sleep when buffer is full. 
    while (1) {
		if (DEBUG) { fprintf(stderr, "producer start\n"); }
        Mutex_lock(&lock);
		while(buffersize >= maxbuffers) {
			if (DEBUG) { fprintf(stderr, "producer wait\n"); }
			Cond_wait(&empty, &lock);
            if (DEBUG) { fprintf(stderr, "producer awake\n"); }
		}
		clientlen = sizeof(clientaddr);
		Mutex_unlock(&lock);
        connfd = Accept(listenfd, (SA *)&clientaddr, (socklen_t *) &clientlen); //Thread blocks here, waiting for connections. Might need to sleep here?
		Mutex_lock(&lock);
		if (put(connfd) != 0) {
			if (DEBUG) { fprintf(stderr, "Put failed"); }
		}
// 		Close(connfd);       
		if (DEBUG) { fprintf(stderr, "signalling consumer\n"); }
		Cond_signal(&fill);
		Mutex_unlock(&lock);
		if (DEBUG) { fprintf(stderr, "producer end\n"); }
    }

}