#include "cs537.h"
#include "request.h"
#include <string.h>

// 
// server.c: A very, very simple web server
//
// To run:
//  server <portnum (above 2000)>
//
// Repeatedly handles HTTP requests sent to this port number.
// Most of the work is done within routines written in request.c
//

// CS537: Parse the new arguments too
void usage() {
    fprintf(stderr, "Usage: %s <port>\n", argv[0]);
    exit(1);
}
void getargs(int *port, int *threads, int *buffers, int *schedalg, int argc, char *argv[])
{
    if (argc != 2)
        usage();
    *port = atoi(argv[1]);
    if (port > 65535 || port < 0) {
        usage();
    }

    *threads = atoi(argv[2]);
    if (threads < 1)
        usage();

    *buffers = atoi(argv[3]);
    if (buffers < 1)
        usage();

    // FIFO = 0, SFF = 1, SFF-BS = 2
    if (strcmp(argv[4], "FIFO") == 0)
        
}


int main(int argc, char *argv[])
{
    int listenfd, connfd, port, clientlen, threads, buffers, schedalg;
    struct sockaddr_in clientaddr;

    getargs(&port, threads, buffers, schedalg, argc, argv);

    // 
    // CS537: Create thread pool
    //

    listenfd = Open_listenfd(port);

    // Add in check for the conditional variables here. This is the producer.
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


    


 
