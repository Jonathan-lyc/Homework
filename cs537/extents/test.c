#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"


int
main (int argc, char* argv[]) {
  int fd = open("open.txt", O_CREATE | O_RDWR | O_EXTENT);
  if(write(fd, "aaaaaaaaaa", 10) != 10) {
	printf(1, "error: write aa %d new file failed\n", 1);
	exit();
  }
  exit();
}
