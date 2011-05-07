#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "syscall.h"
#include "traps.h"


int
main (int argc, char* argv[]) {
  open("open.txt", O_CREATE | O_RDWR | O_EXTENT);
  exit();
}
