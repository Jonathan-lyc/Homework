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
  int fd = open("del.txt", O_CREATE | O_RDWR | O_EXTENT);
  if (fd <= 1) {
    printf(stdout, "file issues?\n");
  }
  int i;
  printf(stdout, "starting delete test\n");
  for (i = 0; i < 65; i++) {
    if(write(fd, "aaaaaaa\n", 8) != 8) {
      printf(stdout, "error: write aa %d new file failed\n", i);
      exit();
    }
  }

  struct stat st;
  fstat(fd, &st);

  printf(stdout, "Used blocks %d and %d\n", st.bladdrs[0], st.bladdrs[0] + 1);
  unlink("del.txt");
  close(fd);

  fd = open("del2.txt", O_CREATE | O_RDWR | O_EXTENT);
  for (i = 0; i < 65; i++) {
    if(write(fd, "bbbbbbb\n", 8) != 8) {
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }`
  }
  fstat(fd, &st);
  
  printf(stdout, "Used blocks %d and %d\n", st.bladdrs[0], st.bladdrs[0] + 1);
  close(fd);
  exit();
}
