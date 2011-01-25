#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "sort.h"

void usage();

int main(int argc, char *argv[]) {
  if (argc != 5) {
    usage();
  }
  char inputfile[50];
  char outputfile[50];

  int i = strcmp(argv[1], "-i");
  int o = strcmp(argv[3], "-i");

  if (i == 0) {
    strcpy(inputfile, argv[2]);
    strcpy(outputfile, argv[4]);
  }
  else if (o == 0) {
    strcpy(inputfile, argv[4]);
    strcpy(outputfile, argv[2]);
  }
  else {
    usage();
  }

  

  return(0);
}

void usage() {
  fprintf(stderr, "usage: zsort -i inputfile -o outputfile\n");
  exit(1);
}
