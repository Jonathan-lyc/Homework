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

#define BUFSIZE (64)
#define DEBUG (1)

void usage();
void fileError(char *file, int input_fd, int output_fd);

int
main(int argc, char *argv[]) {
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

  // Attempt to open output file. Craetes file if it didn't exist.
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
  int bytes = buf.st_size;

  if (DEBUG == 1) {
    printf("%d\n", bytes);
  }

  int *sort_array = malloc(bytes);
  if (sort_array == NULL) {
    fprintf(stderr, "Malloc failed");
  }

  int num_recs = bytes / 128;


  rec_t records[BUFSIZE];
  while (1) {
    int rc;
    if ((rc = read(input_fd, records, BUFSIZE * sizeof(rec_t))) == 0) {
        break;
    }
    int i, j;
    for (i = 0; i < (rc / sizeof(rec_t)); i++) {
      printf("key:%9d rec:", records[i].key);
      for (j = 0; j < NUMRECS; j++) {
        printf("%3d ", records[i].record[j]);
      }
      printf("\n");
    }
  }

  close(input_fd);
  close(output_fd);
  return(0);
}

int
recordcmp (const void *p1, const void *p2) {
  
}

void
usage() {
  fprintf(stderr, "usage: zsort -i inputfile -o outputfile\n");
  exit(1);
}

void
fileError(char *file, int input_fd, int output_fd) {
  fprintf(stderr, "Error: Cannot open file %s\n", file);
  //Errors at this point are irrelevant.
  close(input_fd);
  if (output_fd > 0) {
    close(output_fd);
  }
  exit(1);
}
