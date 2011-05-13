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
  int fd = open("app.txt", O_CREATE | O_RDWR);
  if (fd <= 1) {
    printf(stdout, "file issues?\n");
  }
  int i;
  printf(stdout, "starting coalesce test\n");
  for (i = 0; i < 2; i++) {
    if(write(fd, "aaaaaaa\n", 8) != 8) {
      printf(stdout, "error: write aa %d new file failed\n", i);
      exit();
    }
  }
  close(fd);
  fd = open("app.txt", O_CREATE | O_RDWR);
  if (fd <= 1) {
    printf(stdout, "file issues?\n");
  }
  printf(stdout, "starting coalesce test\n");
  for (i = 0; i < 1; i++) {
    if(write(fd, "aaaaaaa\n", 8) != 8) {
      printf(stdout, "error: write aa %d new file failed\n", i);
      exit();
    }
  }
  struct stat st;
  fstat(fd, &st);
  if (st.size != 520) {
    printf(stdout, "File size different from expected\n");
  }
  else {
    printf(stdout, "coalesce block test complete\n");
  }
  close(fd);
  exit();
}
