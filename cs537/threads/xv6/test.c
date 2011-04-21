#include "types.h"
#include "stat.h"
#include "user.h"

int
main (int argc, char* argv[]) {
  printf(1, "test");
  int i = clone(malloc(4096), 4096);
  printf(1, "i = %d", i);
  exit();
}
