#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"

int stdout = 1;

int
main (int argc, char* argv[]) {
  int fd = open("output.txt", O_CREATE | O_RDWR | O_EXTENT);
  if (fd == 1) {
	printf(stdout, "stdout is the fd?\n");  
  }
  int i;
  for (i = 0; i < 53; i++) {
	if(write(fd, "aaaaaaaaa\n", 10) != 10) {
		printf(stdout, "error: write aa %d new file failed\n", i);
		exit();
	}
	
  }
  close(fd);
  exit();
}
