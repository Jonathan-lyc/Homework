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
  struct stat st = st;
  if (argc != 2) {
    printf(stdout,"FALSE! (CORRECT: stat filename)\n");
    exit();
  }
  int fd = open(argv[1], O_RDWR);
  if (fd < 0) {
	printf(stdout, "FILE DOESN'T EXIST DUMMY!\n");
  }
  
  stat(argv[1], &st);
  
  printf(stdout, "File type = ");
  if (st.type == T_DIR)
    printf(stdout, "T_DIR\n");
  else if (st.type == T_FILE)
    printf(stdout, "T_FILE\n");
  else if (st.type == T_DEV)
    printf(stdout, "T_DEV\n");
  else if (st.type == T_EXTENT)
    printf(stdout, "T_EXTENT\n");
  else
    printf(stdout, "OH NO!!! WHAT DID YOU DO?!?! TYPE = %d\n", st.type);

  printf(stdout, "Links = %d\n", st.nlink);

  printf(stdout, "Size = %d\n", st.size);

  printf(stdout, "Block Addresses:\n");
  int i;
  if (st.type == T_EXTENT) {
    // I don't know what crazy shit has to be done here to get the addresses
  } else {
    for (i = 0; i < NDIRECT + 1; i++) {
      printf(stdout, "  Pointer %d's address = %d\n", i, st.bladdrs[i]);
    }
  }
  exit();
}
