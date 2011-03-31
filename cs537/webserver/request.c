//
// request.c: Does the bulk of the work for the web server.
// 

#include "cs537.h"
#include "request.h"

void requestError(int fd, char *cause, char *errnum, char *shortmsg, char *longmsg) 
{
   char buf[MAXLINE], body[MAXBUF];

   printf("Request ERROR\n");

   // Create the body of the error message
   sprintf(body, "<html><title>CS537 Error</title>");
   sprintf(body, "%s<body bgcolor=""fffff"">\r\n", body);
   sprintf(body, "%s%s: %s\r\n", body, errnum, shortmsg);
   sprintf(body, "%s<p>%s: %s\r\n", body, longmsg, cause);
   sprintf(body, "%s<hr>CS537 Web Server\r\n", body);

   // Write out the header information for this response
   sprintf(buf, "HTTP/1.0 %s %s\r\n", errnum, shortmsg);
   Rio_writen(fd, buf, strlen(buf));
   printf("%s", buf);

   sprintf(buf, "Content-Type: text/html\r\n");
   Rio_writen(fd, buf, strlen(buf));
   printf("%s", buf);

   sprintf(buf, "Content-Length: %d\r\n\r\n", (int) strlen(body));
   Rio_writen(fd, buf, strlen(buf));
   printf("%s", buf);

   // Write out the content
   Rio_writen(fd, body, strlen(body));
   printf("%s", body);

}


//
// Reads and discards everything up to an empty text line
//
void requestReadhdrs(rio_t *rp)
{
   char buf[MAXLINE];

   Rio_readlineb(rp, buf, MAXLINE);
   while (strcmp(buf, "\r\n")) {
      Rio_readlineb(rp, buf, MAXLINE);
   }
   return;
}

//
// Return 1 if static, 0 if dynamic content
// Calculates filename (and cgiargs, for dynamic) from uri
//
int requestParseURI(char *uri, char *filename, char *cgiargs) 
{
	char *ptr;
// 	if (!strstr(uri, "cgi")) {
// 		fprintf(stderr, "    not found: %s\n", uri); 
// 	}
// 	else {
// 		fprintf(stderr, "    found: %s\n", uri); 
// 	}
	if (!strstr(uri, "cgi")) {
		// static
		fprintf(stderr, "    staticbegin: %s\n", filename); 
		strcpy(cgiargs, "");
		sprintf(filename, ".%s", uri);
		if (uri[strlen(uri)-1] == '/') {
			strcat(filename, "home.html");
		}
		fprintf(stderr, "    staticend: %s\n", filename); 
		return 1;
	} 
	else {
		// dynamic
		fprintf(stderr, "    dynamicbegin: %s\n", filename);
		ptr = index(uri, '?');
		if (ptr) {
			strcpy(cgiargs, ptr+1);
			*ptr = '\0';
		} else {
			strcpy(cgiargs, "");
		}
		fprintf(stderr, "    dynamicend: %s\n", filename); 
		sprintf(filename, ".%s", uri);
		return 0;
	}
}

// 
// Fills in the filetype given the filename
//
void requestGetFiletype(char *filename, char *filetype)
{
   if (strstr(filename, ".html")) 
      strcpy(filetype, "text/html");
   else if (strstr(filename, ".gif")) 
      strcpy(filetype, "image/gif");
   else if (strstr(filename, ".jpg")) 
      strcpy(filetype, "image/jpeg");
   else 
      strcpy(filetype, "test/plain");
}

void requestServeDynamic(int fd, char *filename, char *cgiargs, request stats)
{
//     fprintf(stdout, "dyn fn: %s, fd: %d\n", filename, fd);
    long int req_arrival, req_dispatch;
	char buf[MAXLINE], *emptylist[] = {NULL};
	char *fn = filename;
	req_arrival = stats.req_arrival;
	req_dispatch = stats.req_dispatch;
	
// 	if (strcmp(fn, "./home.html") == 0) {
// 		fprintf(stderr, "   ERROR home in fn in exec\n");
// 		memcpy(fn, "./output.cgi", MAXLINE);
// 		memcpy(cgiargs, "0.3", MAXLINE);
// 	}
// 	if (strcmp(filename, "./home.html") == 0) {
// 		fprintf(stderr, "   ERROR home in filename in exec\n");
// 		memcpy(filename, "./output.cgi", MAXLINE);
// 		memcpy(cgiargs, "0.3", MAXLINE);
// 	}

	// The server does only a little bit of the header.  
	// The CGI script has to finish writing out the header.
	sprintf(buf, "HTTP/1.0 200 OK\r\n");
	sprintf(buf, "%sServer: CS537 Web Server\r\n", buf);

	/* CS537: Your statistics go here -- fill in the 0's with something useful! */
	//int arrival = req_arrival.tv_usec / 1000;
// 	fprintf(stderr, "arrival: %d\n", arrival);
	sprintf(buf, "%sStat-req-arrival: %ld\r\n", buf, req_arrival);
	sprintf(buf, "%sStat-req-dispatch: %ld\r\n", buf, req_dispatch);
	sprintf(buf, "%sStat-thread-id: %d\r\n", buf, stats.thread_id);
	sprintf(buf, "%sStat-thread-count: %d\r\n", buf, stats.thread_count);
	sprintf(buf, "%sStat-thread-static: %d\r\n", buf, stats.thread_static);
	sprintf(buf, "%sStat-thread-dynamic: %d\r\n", buf, stats.thread_dynamic);

	Rio_writen(fd, buf, strlen(buf));
	if (Fork() == 0) {
		/* Child process */
// 		fprintf(stderr, "exec - fn: %s, fd: %d cgi: %s\n", fn, fd, cgiargs); // <-- proves that cgiargs is messed up and pissing me off.

		Setenv("QUERY_STRING", cgiargs, 1);
		/* When the CGI process writes to stdout, it will instead go to the socket */
		Dup2(fd, STDOUT_FILENO);
		Execve(fn, emptylist, environ);
	}
	Wait(NULL);
}


void requestServeStatic(int fd, char *filename, int filesize, request stats) 
{
//     fprintf(stdout, "static fn: %s, fd: %d\n", filename, fd);
	struct timeval tv;
	//rd_end is also when the serving completes
	int srcfd;
	char *srcp, filetype[MAXLINE], buf[MAXBUF];
	char tmp = 0;
	int i;

	requestGetFiletype(filename, filetype);

	gettimeofday(&tv, NULL);
    int long rd_begin = (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
    
	srcfd = Open(filename, O_RDONLY, 0);

	// Rather than call read() to read the file into memory, 
	// which would require that we allocate a buffer, we memory-map the file
	srcp = Mmap(0, filesize, PROT_READ, MAP_PRIVATE, srcfd, 0);
	Close(srcfd);
// 	fprintf(stderr, "stat - fn: %s, fd: %d\n", filename, fd);
	// The following code is only needed to help you time the "read" given 
	// that the file is memory-mapped.  
	// This code ensures that the memory-mapped file is brought into memory 
	// from disk.

	// When you time this, you will see that the first time a client 
	//requests a file, the read is much slower than subsequent requests.
	for (i = 0; i < filesize; i++) {
		tmp += *(srcp + i);
	}
	gettimeofday(&tv, NULL);
    int long rd_end = (tv.tv_sec * 1000) + (tv.tv_usec / 1000);

	// finish time calculations
	int long req_begin = stats.req_arrival;
	int long req_dispatch = stats.req_dispatch;
    int long rd_diff = rd_end - rd_begin;
    int long req_diff = rd_end - req_begin;
/*    fprintf(stderr, "rd_end: %ld, rd_begin: %ld, comp: %ld\n", req_diff);*/
	
	sprintf(buf, "HTTP/1.0 200 OK\r\n");
	sprintf(buf, "%sServer: CS537 Web Server\r\n", buf);
// 	fprintf(stderr, "arrival: %d\n", ((int) req_begin.tv_usec / 1000));
	// CS537: Your statistics go here -- fill in the 0's with something useful!
	sprintf(buf, "%sStat-req-arrival: %ld\r\n", buf, stats.req_arrival);
	sprintf(buf, "%sStat-req-dispatch: %ld\r\n", buf, req_dispatch);
	sprintf(buf, "%sStat-req-read: %ld\r\n", buf, rd_diff);
	sprintf(buf, "%sStat-req-complete: %ld\r\n", buf, req_diff);
	sprintf(buf, "%sStat-thread-id: %d\r\n", buf, stats.thread_id);
	sprintf(buf, "%sStat-thread-count: %d\r\n", buf, stats.thread_count);
	sprintf(buf, "%sStat-thread-static: %d\r\n", buf, stats.thread_static);
	sprintf(buf, "%sStat-thread-dynamic: %d\r\n", buf, stats.thread_dynamic);

	sprintf(buf, "%sContent-Length: %d\r\n", buf, filesize);
	sprintf(buf, "%sContent-Type: %s\r\n\r\n", buf, filetype);

	Rio_writen(fd, buf, strlen(buf));

	//  Writes out to the client socket the memory-mapped file 
	Rio_writen(fd, srcp, filesize);
	Munmap(srcp, filesize);
    Close(fd);
}

request requestInit(request id) {
	int fd = id.fd;
	request stats;
	stats.req_arrival = id.req_arrival;
	
	int is_static;
	struct stat sbuf;
	char buf[MAXLINE], method[MAXLINE], uri[MAXLINE], version[MAXLINE];
	char filename[MAXLINE], cgiargs[MAXLINE];
	rio_t rio;
   
	stats.size = -1;

	Rio_readinitb(&rio, fd);
	Rio_readlineb(&rio, buf, MAXLINE);
	sscanf(buf, "%s %s %s", method, uri, version);

	printf("%s %s %s\n", method, uri, version);

	if (strcasecmp(method, "GET")) {
		requestError(fd, method, "501", "Not Implemented", 
			"CS537 Server does not implement this method");
		return stats;
	}
	requestReadhdrs(&rio);

	is_static = requestParseURI(uri, filename, cgiargs);
// 	fprintf(stderr, "          filename: %s, static: %d\n", filename, is_static);
// 	if (is_static == 0&& strcmp(filename, "./home.html") == 0) {
// 		fprintf(stderr, " umm fixing??\n");
// 		memcpy(filename, "./output.cgi", MAXLINE);
// 	}
	
	if (stat(filename, &sbuf) < 0) {
		requestError(fd, filename, "404", "Not found", "CS537 Server could not find this file");
		return stats;
	}
	stats.fd = fd;
	stats.sbuf = sbuf;
	stats.size = sbuf.st_size;
	stats.filename = filename;
// 	fprintf(stderr, "cgiargs b4 store: %s   ", cgiargs);
	stats.cgiargs = cgiargs;
	stats.is_static = is_static;
	return stats;
}

// handle a request
void requestHandle(request stats)
{
	struct stat sbuf = stats.sbuf;
	int is_static = stats.is_static;
	int fd = stats.fd;
	char filename[MAXLINE];
	memcpy(filename, stats.filename, MAXLINE);
	char cgiargs[MAXLINE];
	memcpy(cgiargs, stats.cgiargs, MAXLINE);
// 	fprintf(stderr, "cgiargs after store: %s   ", cgiargs);

    if (is_static) {
		if (!(S_ISREG(sbuf.st_mode)) || !(S_IRUSR & sbuf.st_mode)) {
			requestError(fd, filename, "403", "Forbidden", "CS537 Server could not read this file");
			return;
		}
		requestServeStatic(fd, filename, sbuf.st_size, stats);
	} 
	else {
		if (!(S_ISREG(sbuf.st_mode)) || !(S_IXUSR & sbuf.st_mode)) {
			requestError(fd, filename, "403", "Forbidden", "CS537 Server could not run this CGI program");
			return;
		}
		requestServeDynamic(fd, filename, cgiargs, stats);
   }
}