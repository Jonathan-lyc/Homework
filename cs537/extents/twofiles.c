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
//   int fd = open("output.txt", O_CREATE | O_RDWR);
  int fd = open("two1.txt", O_CREATE | O_RDWR | O_EXTENT);
  if (fd <= 1) {
    printf(stdout, "file issues?\n");
  }
  int fd1 = open("two2.txt", O_CREATE | O_RDWR | O_EXTENT);
  if (fd1 <= 1) {
    printf(stdout, "file issues?\n");
  }
  
  printf(stdout, "starting twofiles test\n");
  int i;
  for (i = 0; i < 65; i++) {
    if(write(fd, "aaaaaaa\n", 8) != 8) {
      printf(stdout, "error: write aaaaaaa %d new file failed\n", i);
      exit();
    }
    if(write(fd1, "bbbbbbb\n", 8) != 8) {
      printf(stdout, "error: write bbbbbbb %d new file failed\n", i);
      exit();
    }
  }
  
  

  
  struct stat st1, st2;
  
  fstat(fd, &st1);
  fstat(fd1, &st2);
  if (st1.size != 520) {
    printf(stdout, "File size 1 different from expected, size = %d\n", st1.size);
  }
  if (st2.size != 520) {
    printf(stdout, "File size 2 different from expected, size = %d\n", st2.size);
  }
  printf(stdout, "twofiles test complete!\n");
  close(fd);
  close(fd1);
  
  exit();
}
