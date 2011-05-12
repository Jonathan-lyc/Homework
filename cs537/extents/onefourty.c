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
  
  printf(stdout, "starting 140 block test\n");
  int i, j;
  int onefourty = open("onefourty.txt", O_CREATE | O_RDWR | O_EXTENT);
  for (j = 0; j < 141; j++) { 
	for (i = 0; i < 64; i++) {
	  if(write(onefourty, "aaaaaaa\n", 8) != 8) {
		  printf(stdout, "error: write aa %d new file failed\n", i);
		  exit();
	  }
	}
  }
  printf(stdout, "140 block test complete\n");
  close(onefourty);
  exit();
}