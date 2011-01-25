#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "sort.h"

void usage();
void closeFiles();

int main(int argc, char *argv[]) {
  if (argc != 5) {
    usage();
  }
  char input[50];
  char output[50];

  int i = strcmp(argv[1], "-i");
  int o = strcmp(argv[3], "-i");

  if (i == 0) {
    strcpy(input, argv[2]);
    strcpy(output, argv[4]);
  }
  else if (o == 0) {
    strcpy(input, argv[4]);
    strcpy(output, argv[2]);
  }
  else {
    usage();
  }

  //Check that input is readable and output is writable. This may be wrong..
  if (access(input, R_OK) == -1 && access(output, W_OK) == -1 ) {
    if (access(input, R_OK) != -1) {
      fprintf(stderr, "Input file is not readable. Please check permissions.\n");
      exit(1);
    }
    else {
      fprintf(stderr, "Output file is not writable. Please check permissions.\n");
      exit(1);
    }

  }

  //Get file pointers for input and output. Must now call close before
  //any exit
  FILE *inputfile;
  FILE *outputfile;
  inputfile = fopen(input, "r");
  outputfile = fopen(output, "w");
  if (inputfile == NULL) {
    fprinf(stderr, "Input file %s is not readable. Please check permissions and that the file actually exists.\n", input);
    closeFiles();
    exit(1);
  }
  if (outputfile == NULL) {
    fprintf(stderr, "Output file %s is not writable. Please check permissions.\n", output);
    close();
    exit(1);
  }

  return(0);
}

void usage() {
  fprintf(stderr, "usage: zsort -i inputfile -o outputfile\n");
  exit(1);
}

void closeFiles() {
  int i;
  int o;
  i = fclose(inputfile);
  o = fclose(outputfile);
  if (i != 0) {
    fprintf(stderr, "Error closing input file %s", input);
    exit(1);
  }
  if (o !- 0) {
    fprintf(stderr, "Error closing output file %s", output);
    exit(1);
  }
}
