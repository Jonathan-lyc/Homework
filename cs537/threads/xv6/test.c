#include "types.h"
#include "stat.h"
#include "user.h"
#include "linkedlist.h"

int
main (int argc, char* argv[]) {
  printf(1, "test");
  char* stack = malloc(4096);
  int i = clone(stack, 4096);
  
  printf(1, "i = %d", i);
/*  struct lock_t t;
//   t = (struct lock_t)malloc(sizeof(struct lock_t));
  lock_init(&t);*/
//   int i;
//   for (i = 0; i < 10; i++) {
//     ll_add(i);
//   }
//   ll_print();
//   ll_coolj();
  exit();
}
