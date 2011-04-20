#include "types.h"
#include "stat.h"
#include "user.h"

int
main (int argc, char* argv[]) {
  int size = 4;
  int stack[size];
  int i = clone((void *) stack, size);
  printf(1, "i = %d", i);
  exit();
}
