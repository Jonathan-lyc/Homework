#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

int
main(int argc, char *argv[])
{
    printf("begin\n");

    int rc = fork();
    if (rc == 0) {
	// child
	printf("child\n");
    } else if (rc > 0) {
	// parent
	printf("parent early\n");
	int wc = wait(NULL);
	printf("parent: waited and got %d %d\n", rc, wc);
    } else {
	perror("fork");
    }

    return 0;
}

