#ifndef __REQUEST_H__
#include <sys/time.h>

typedef struct {
  int fd;
  struct stat sbuf;
  int size;
  char *cgiargs;
  char *filename;
  int is_static;
  //Request stats
  struct timeval req_arrival;
  struct timeval req_dispatch;
  //Thread stats
  int thread_id;
  int thread_count;
  int thread_static;
  int thread_dynamic;
} request;
void requestHandle(request stats);
request requestInit(request id);

#endif
