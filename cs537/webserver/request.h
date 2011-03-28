#ifndef __REQUEST_H__

typedef struct request_stats_t {
  int fd;
  char buf[MAXLINE];
  rio_t rio;
  int size;
} request;
void requestHandle(request stats);
request requestSize(int fd);

#endif
