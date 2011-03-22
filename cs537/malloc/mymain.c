#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include "mem.h"

int
main(int argc, char *argv[]) {
//   int rc = Mem_Init(2000, 2);
//   printf("the return code was: %d\n", rc);
//   printf("merror: %d\n", rc);
//   Mem_Dump();
//   printf("Malloc:\n");
//   void *a = Mem_Alloc(10);
//   void *b = Mem_Alloc(30);
//   void *c = Mem_Alloc(80);
//   Mem_Dump();
//   printf("Free:\n");
//   printf("Free a\n");
//   Mem_Free(a);
//   printf("Free c\n");
//   Mem_Free(c);
//   printf("Free b\n");
//   Mem_Free(b);
//   Mem_Dump();
  
   assert(Mem_Init(4096, 0) == 0);
   assert(Mem_Alloc(1) != NULL);
   assert(Mem_Alloc(5) != NULL);
   assert(Mem_Alloc(14) != NULL);
   assert(Mem_Alloc(8) != NULL);
   assert(Mem_Alloc(1) != NULL);
   assert(Mem_Alloc(4) != NULL);
   assert(Mem_Alloc(9) != NULL);
   assert(Mem_Alloc(33) != NULL);
   assert(Mem_Alloc(55) != NULL);
  return 0;
}
