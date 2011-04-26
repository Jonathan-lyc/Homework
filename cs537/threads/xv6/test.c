#include "types.h"
#include "stat.h"
#include "user.h"
#include "linkedlist.h"
#include "thread.h"

int
main (int argc, char* argv[]) {
  printf(1, "test");
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
  char* stack = malloc(4096);
/*  printf(1, "stack outside %d\n", stack[0]);*/
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

//   while(1){;}
  
  int pid = getpid();
  printf(1, "pid about to wait %d\n", pid);
  int ret = wait();
  printf(1, "wait returned %d\n", ret);

  printf(1, "pid: %d exiting\n", pid);
  exit();
}
