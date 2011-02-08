#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

int
main(int argc, char *argv[])
{
    printf("begin\n");

    int rc = fork();
    if (rc == 0) {
	// child
	char *myargv[3];
	myargv[0] = strdup("ls");
	myargv[1] = strdup("-i");
	myargv[2] = NULL; // important

	execvp(myargv[0], myargv);
	// execvp() only returns if there is an error
	perror("execvp");
	exit(1); // important!

    } else if (rc > 0) {
	// parent
	(void) wait(NULL);
	printf("end\n");
    } else {
	perror("fork");
    }

    return 0;
}

