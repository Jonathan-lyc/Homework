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
#define DEBUG (0)

void usage();
void fileError(char *file, int input_fd, int output_fd);
int recordcmp(const void *p1, const void *p2);

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
  int num_recs = bytes / 128;

  //Malloc the array, error out if Malloc fails
  rec_t *sort_array = malloc(sizeof(rec_t) * num_recs);
  if (sort_array == NULL) {
    fprintf(stderr, "Malloc failed");
    exit(1);
  }
  int i;
  int j = 0;

  //Read in file, put items into the array.
  rec_t records[BUFSIZE];
  while (1) {
    int rc;
    if ((rc = read(input_fd, records, BUFSIZE * sizeof(rec_t))) == 0) {
        break;
    }

    for (i = 0; i < (rc / sizeof(rec_t)); i++) {
      if(DEBUG == 1) {
        printf("%d\n", records[i].key);
      }
      sort_array[j] = records[i];
      j++;
    }
  }

  //Print out index and key
  if (DEBUG == 1) {
    int k;
    for (k = 0; k < num_recs; k++) {
      printf("%d, %d\n", k, sort_array[k].key);
    }
  }

  //Sort the array!!
  qsort(sort_array, num_recs, sizeof(rec_t), recordcmp);

  //Print all records' keys.
  if (DEBUG == 0) {
    printf("Qsort finished");
    int k;
    for (k = 0; k < num_recs; k++) {
      printf("%d, %d\n", k, sort_array[k].key);
    }
  }

  //Write output to file
  int write_err = write(output_fd, sort_array, sizeof(rec_t) * num_recs);
  if (write_err == 0) {
    fileError(output, input_fd, output_fd);
  }

  close(input_fd);
  close(output_fd);
  return(0);
}

//Qsort method for comparing two records
int
recordcmp(const void *p1, const void *p2) {
  const int a1 = ((rec_t *)p1)->key;
  const int a2 = ((rec_t *)p2)->key;
  //printf("%d, %d\n", a1, a2);
  if (a1 > a2) {
    return 1;
  }
  else if (a1 < a2) {
    return -1;
  }
  else {
    return 0;
  }
}

//Print usage
void
usage() {
  fprintf(stderr, "usage: zsort -i inputfile -o outputfile\n");
  exit(1);
}

//Whenever any error occurs in reading/writing the file,
//this function prints the appropriate message and makes
//sure the files get closed before exiting.
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
