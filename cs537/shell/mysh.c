#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAXINPUT 256

int prompt();
void error();
void batch();

int
main(int argc, char *argv[]){
  if (argc > 2) {
    error();
  }
  //Interactive mode
  if (argc == 1) {
    prompt();
  }
  if (argc == 2) {
    batch();
  }

  prompt();
  return 0;
}

int
prompt() {
  char *input = malloc(MAXINPUT);
  if (input == NULL) {
    error();
    return 1;
  }

  printf("mysh> ");
  fgets (input, MAXINPUT, stdin);
  if (input[strlen (input) -1] == '\n') {
    input[strlen (input) - 1] = '\0';
  }
  printf("\nYou typed: %s\n", input);

  //Get the command
  int i;
  return 0;
}

void
error() {
  printf("Error\n");
  exit(1);
}

void
batch() {
  printf("Was batch mode fun?\n");
  exit(1);
}
