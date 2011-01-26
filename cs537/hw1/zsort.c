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
void fileError(char *file, int input_fd, int output_fd);

int main(int argc, char *argv[]) {
  // The following code was inspired by generate.c :)

  // args
  char *input = "";
  char *output = "";

  if (argc != 5) {
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
     fileError(input, input_fd, 0);
  }

  // Attempt to open output file.
  int output_fd = open(output, O_WRONLY|O_CREAT|O_TRUNC, S_IRWXU);
  if (output_fd < 0) {
    fileError(input, input_fd, output_fd);
  }

  // Get size of file for efficient malloc
  struct stat buf;
  int err = fstat(input_fd, &buf);
  if (err != 0) {
    fileError(input, input_fd, output_fd);
  }
  int size = buf.st_size;
  printf("%d\n", size);

  int *sort_array = malloc(size);
  if (sort_array == NULL) {
    fprintf(stderr, "Malloc failed");
  }
  return(0);
}

void usage() {
  fprintf(stderr, "usage: zsort -i inputfile -o outputfile\n");
  exit(1);
}

void fileError(char *file, int input_fd, int output_fd) {
  fprintf(stderr, "Error: Cannot open file %s\n", file);
  //Errors at this point are irrelevant.
  close(input_fd);
  if (output_fd > 0) {
    close(output_fd);
  }
  exit(1);
}
