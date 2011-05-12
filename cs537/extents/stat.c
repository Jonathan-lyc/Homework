#include "stat.h"
#include "types.h"
#include "file.h"
#include "defs.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"


int
main (int argc, char* argv[]) {
  if (argc != 2) {
    cprintf( "FALSE! (CORRECT: stat filename)\n");
    exit();
  }

  char *path = argv[1];
  struct inode *ip;
  struct stat *sp;

  if ((ip = namei(path)) == 0) {
    cprintf( "Could not get inode, Sorry :\(\n");
    exit();
  }

  stati(ip, sp);

  cprintf( "File type = ");
  if (sp->type == T_DIR)
    cprintf( "T_DIR\n");
  else if (sp->type == T_FILE)
    cprintf( "T_FILE\n");
  else if (sp->type == T_DEV)
    cprintf( "T_DEV\n");
  else if (sp->type == T_EXTENT)
    cprintf( "T_EXTENT\n");
  else
    cprintf( "OH NO!!! WHAT DID YOU DO?!?!\n");

//   cprintf( "Links = %d\n", sp->nlink);
// 
//   cprintf( "Size = %d\n", sp->size);
// 
//   cprintf( "Block Addresses:\n");
//   int i;
//   if (sp->type == T_EXTENT) {
//     // I don't know what crazy shit has to be done here to get the addresses
//   } else {
//     for (i = 0; i < NDIRECT + 1; i++) {
//       cprintf( "  Pointer %d's address = %d\n", i, sp->bladdrs[i]);
//     }
//   }

  exit();
}
