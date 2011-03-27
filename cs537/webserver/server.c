#include "cs537.h"
#include "request.h"
#include <string.h>
#include "shortcuts.h"

// 
// server.c: A very, very simple web server
//
// To run:
//  server <portnum (above 2000, below 65535)> <number of threads> <number of buffers> <scheduler>
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
int buffersize = 0;
int maxbuffers;
int *buffer;


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
	if (schedalg == 0) {
		if (buffersize < maxbuffers) {
			buffer[buffersize] = dup(fd);
			buffersize++;
			return 0;
		}
		else {
			return -1;
		}
	}
	// Smallest File First
	else if (schedalg == 1) {
	    return 0;
	}
	// Smallest File First with Bounded Starvation
	else if (schedalg == 2) {
	    return 0; 
	}
	else {
	    printf("schedalg not within valid range of 0 - 2");
	    exit(3);
	}
	return 0;
}

// Queue get
// Return -1 if nothing left, else returns fd
int get() {
	// FIFO
	if (schedalg == 0) {
	   if (buffersize == 0) {
		  return -1;
	   }
	   else {
		  buffersize--;
		  int fd = dup(buffer[buffersize]);
		  return fd;
	   }
	}
	// Smallest File First
	else if (schedalg == 1) {
	   return 0;
	}
	// Smallest File First with Bounded Starvation
	else if (schedalg == 2) {
	  return 0; 
	}
	else {
	  printf("schedalg not within valid range of 0 - 2");
	  exit(3);
	}
	return 0;
}

void consumer(int arg) {
	while(1) {
	  fprintf(stderr, "consumer start\n");
	  Mutex_lock(&lock);
	  while(buffersize == 0){
		  fprintf(stderr, "consumer wait\n");
		  Cond_wait(&fill, &lock);
	  }
	  fprintf(stderr, "consumer awake\n");
	  int connfd = get();
	  requestHandle(connfd);
	  Cond_signal(&empty);
	  Mutex_unlock(&lock);
	  fprintf(stderr, "consumer end\n");
	}
}
int main(int argc, char *argv[])
{
    int listenfd, connfd, port, clientlen, threads, buffers;
    struct sockaddr_in clientaddr;

    getargs(&port, &threads, &buffers, argc, argv);
    
	//Buffers incoming connections
	buffer = (int *) malloc(buffers * sizeof(int)); 
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
	pthread_t pid, cid[threads];
	
    // 
    // CS537: Create thread pool of consumers
    //
	int i;
	for (i = 0; i < threads; i++) {
		Pthread_create(&cid[i], consumer);
	}
    listenfd = Open_listenfd(port);

    // Add in check for the conditional variables here.
	// This is the producer thread. it will sleep when buffer is full. 
    while (1) {
		fprintf(stderr, "producer start\n");
        Mutex_lock(&lock);
		while(buffersize == maxbuffers) {
			fprintf(stderr, "producer wait\n");
			Cond_wait(&empty, &lock);
		}
		Mutex_unlock(&lock);
		fprintf(stderr, "producer awake\n");
		clientlen = sizeof(clientaddr);
        connfd = Accept(listenfd, (SA *)&clientaddr, (socklen_t *) &clientlen); //Thread blocks here, waiting for connections. Might need to sleep here?
		Mutex_lock(&lock);
		if (put(connfd) != 0) {
			fprintf(stderr, "Put failed");
		}
		Close(connfd);       
		fprintf(stderr, "signalling consumer\n");
		Cond_signal(&fill);
		Mutex_unlock(&lock);
		fprintf(stderr, "producer end\n");
    }

}


    


 
