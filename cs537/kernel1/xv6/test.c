#include "types.h"
#include "stat.h"
#include "user.h"

int
main (int argc, char* argv[]) {
	int n = 23;
	int counts[n];
	printf(1, "Hello world!\n");
	getcount(counts, n);
	printf(1, "count 0: %d\n", counts[22]);
	exit();
}
