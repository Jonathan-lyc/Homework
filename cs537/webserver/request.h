#ifndef __REQUEST_H__
#include <sys/time.h>

typedef struct {
  int fd;
  struct stat sbuf;
  int size;
  char cgiargs[8192];
  char filename[8192];
  int is_static;
  //Request stats
  long int req_arrival;
  long int req_dispatch;
  //Thread stats
  int thread_id;
  int thread_count;
  int thread_static;
  int thread_dynamic;
} request;
void requestHandle(request stats);
request requestInit(request id);

#endif
