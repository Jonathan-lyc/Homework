#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "sort.h"

void usage();

int main(int argc, char *argv[]) {
  // The following code was inspired by generate.c :)

  // args
  char input[50];
  char output[50];

  int c;
  while((c = getopt(argc, argv, "i:o:")) != -1 {
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
  int input_fd = open(input, O_RONLY, S_IRWXU);
  if (input_fd < 0) {
    fprintf(stderr, "Error: Cannot open file %s", input);
  }

  // Attempt to open output file.
  int output_fd = open(output, O_WRONLY|O_CREAT|O_TRUNC, S_IRWXU);
  if (output_fd < 0) {
    fprintf(stderr, "Error: Cannot open file %s", output);
  }

  closeFiles(inputfile, input, outputfile, output);
  return(0);
}

void usage() {
  fprintf(stderr, "usage: zsort -i inputfile -o outputfile\n");
  exit(1);
}

