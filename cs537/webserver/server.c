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
int schedalg;
int epoch = 5; // Only used if scheduler is SFF-BS 

void usage(char *argv[]) {
    fprintf(stderr, "Usage: %s <port>\n", argv[0]);
    exit(1);
}

void getargs(int *port, int *threads, int *buffers, int argc, char *argv[])
{
    if (argc != 5) {
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
    if (*buffers < 1) {
        usage(argv);
	}
    // FIFO = 0, SFF = 1, SFF-BS = 2
    if (strcmp(argv[4], "FIFO") == 0) {
        schedalg = 0;
	}
	else if (strcmp(argv[4], "SFF") == 0) {
	    schedalg = 1; 
	}
	else if (strcmp(argv[4], "SFF-BS") == 0) {
	    schedalg = 2; 
	}
	else {
	  usage(argv);
	}
}

// Queue get/put
void put (int fd) {
	printf("Put worked");
}

int get () {
	// FIFO
	if (schedalg == 0) {
	   return 0;
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
}

void *consumer(int *arg) {
	printf("%d", *arg);
}
int main(int argc, char *argv[])
{
    int listenfd, connfd, port, clientlen, threads, buffers;
    struct sockaddr_in clientaddr;

    getargs(&port, &threads, &buffers, argc, argv);
    
	//Buffers incoming connections
	int *buffer = (int *) malloc(buffers * sizeof(int)); 
	if (buffer == NULL) {
	  // Malloc failed, must be out of memory.
	  printf("Malloc failed");
	  exit(2);
	}
	
	// cid will be the container for threads
	pthread_t pid, cid[threads];
	int i;
	for (i = 0; i < threads; i++) {
		Pthread_create(&cid[i], consumer);
	}
	
	
    // 
    // CS537: Create thread pool of consumers
    //
    listenfd = Open_listenfd(port);

    // Add in check for the conditional variables here.
	// This is the producer thread. it will sleep when buffer is full. 
    while (1) {
        clientlen = sizeof(clientaddr);
        connfd = Accept(listenfd, (SA *)&clientaddr, (socklen_t *) &clientlen);
        //
        // CS537: In general, don't handle the request in the main thread.
        // Save the relevant info in a buffer and have one of the worker threads
        // do the work.
        //
        requestHandle(connfd);

        Close(connfd);
    }

}


    


 
