#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

int
main(int argc, char *argv[])
{
    int x = 1;
    printf("begin\n");
    int rc = fork();
    printf("end: %d %d\n", rc, x);


    return 0;
}

