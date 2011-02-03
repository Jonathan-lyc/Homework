#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAXINPUT (256)
#define MAXCOMMANDS (86) //Should be MAXINPUT/3 (2 letter cmds + ;)
#define DEBUG (1)

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
    while (1) {
      prompt();
    }
  }
  if (argc == 2) {
    batch();
  }
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
  int a = fgets (input, MAXINPUT, stdin);
  //Check that fgets didn't have an error.
  if (a = NULL) {
    error();
  }
  //Take out newline, turn to null terminated string
  if (input[strlen (input) -1] == '\n') {
    input[strlen (input) - 1] = '\0';
  }

  if (DEBUG == 1) {
    printf("\nYou typed: %s\n", input);
  }
  int i;
  char *result = NULL;
  char delim[] = ";";
  result = strtok(input, delim);
  while (result != NULL ) {
    printf("%s\n", result);
    result = strtok(input, delim);
  }
  //Break up on ; into array
  //Go through each complete command, break into args
  //Run command
  return 0;
}

int
command_handler(char *commands) {

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
