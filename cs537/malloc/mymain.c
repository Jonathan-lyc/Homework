#include <stdio.h>
#include <stdlib.h>
#include "mem.h"

int
main(int argc, char *argv[]) {
  int rc = Mem_Init(4096, 0);
  printf("the return code was: %d\n", rc);
  printf("merror: %d\n", rc);
  Mem_Dump();
  printf("Malloc\n");
  Mem_Alloc(100);
  Mem_Alloc(200);
  Mem_Alloc(400);
  Mem_Dump();
  return 0;
}
