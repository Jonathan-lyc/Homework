#include "types.h"
#include "stat.h"
#include "user.h"
#include "linkedlist.h"
#include "thread.h"

struct lock_t t;

void update(int runs) {
  printf(1, "runs = %d\n", runs);
  int pid = getpid();
  printf(1, "pid %d starting update\n", pid);
  int i;
  for (i = 0; i < runs; i++) {
	lock_acquire(&t);
    ll_add(i);
	lock_release(&t);
  }
}

void thread_create(void *(*start_routine)(void*), void *arg)
{
//   Possibly need to lock around creating the stack and calling clone
//   lock_acquire(&t);
  char* stack = malloc(4096);
  clone(stack, 4096);
//   lock_release(&t);
  (*start_routine)(arg);
  
  return;
}
/*  printf(1, "Clone returns = %d\n", rc);*/

int
main (int argc, char* argv[]) {
/*  printf(1, "Beginning Test\n");*/
//   struct lock_t lock;
//   lock = *(struct lock_t *)malloc(sizeof(struct lock_t));
//   lock_acquire(&lock);
<<<<<<< HEAD
  int parent = getpid();
  char* stack = malloc(4096);
/*  printf(1, "stack outside %d\n", stack[0]);*/
  clone(stack, 4096);
  
/*  printf(1, "Clone returns = %d\n", rc);*/
//   struct lock_t t;
//   lock_init(&t);
//   int i;
//   for (i = 0; i < 10; i++) {
//     ll_add(i);
//   }
//   ll_print();
//   ll_coolj();

  int pid = getpid();
    if (pid == parent) {
        int ret = wait();
        printf(1, "wait returned %d\n", ret);
    }
=======
  if (argc != 3 || atoi(argv[1]) < 1 || atoi(argv[2]) < 1) {
	printf(1, "Usage: test numberOfThreads numberOfRuns\n");
	exit();
  }
  int threads = atoi(argv[1]);
  lock_init(&t);
  int parent = getpid();
/*  printf(1, "stack outside %d\n", stack[0]);*/
  void (*fnc)(int);
  fnc = &update;
  
  int i;
  for (i = 0; i < threads; i++) {
	thread_create((void*)fnc, (int*)atoi(argv[2]));
  }
   
  int pid = getpid();
  if (pid == parent) {
	int ret = 0;
	for (i = 0; i < threads; i++) {
	  ret = wait();
	  printf(1, "wait returned %d\n", ret);
	}	
	ll_count();
  }
>>>>>>> d2fde116ec48de7cdd2c93c7ff852824130cc81a

  printf(1, "pid: %d exiting\n", pid);
  
  //Prints out the final count
  exit();
}
