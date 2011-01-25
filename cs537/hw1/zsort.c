#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <assert.h>
#include <ctype.h>
#include <string.h>
#include "sort.h"
#include <sys/types.h>
#include <sys/stat.h>


void usage();

int main(int argc, char *argv[]) {
  // The following code was inspired by generate.c :)

  // args
  char *input;
  char *output;

  if (argc != 4) {
    usage();
  }
  int c;
  while ((c = getopt(argc, argv, "i:o:")) != -1) {
    switch (c) {
    case 'i':
      input = strdup(optarg);
      break;
    case 'o':
      output = strdup(optarg);
      break;
    default:
      usage();
    }
  }

  // Attempt to open input file.
  int input_fd = open(input, O_RDONLY, S_IRWXU);
  if (input_fd < 0) {
    fprintf(stderr, "Error: Cannot open file %s", input);
  }

  // Attempt to open output file.
  int output_fd = open(output, O_WRONLY|O_CREAT|O_TRUNC, S_IRWXU);
  if (output_fd < 0) {
    fprintf(stderr, "Error: Cannot open file %s", output);
  }

  // Get size of file for efficient malloc

  return(0);
}

void usage() {
  fprintf(stderr, "usage: zsort -i inputfile -o outputfile\n");
  exit(1);
}

