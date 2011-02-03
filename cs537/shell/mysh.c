#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define MAXINPUT (512)
#define MAXCOMMANDS (171) //Should be MAXINPUT/3 (2 letter cmds + ;)
#define DEBUG (1)

int prompt();
void error();
void batch();
void command_handler(char *commands, int fp, int background);

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
  char *a = fgets(input, MAXINPUT, stdin);
  //Check that fgets didn't have an error.
  if (a == NULL) {
    error();
  }
  //Take out newline, turn to null terminated string
  if (input[strlen (input) -1] == '\n') {
    input[strlen (input) - 1] = '\0';
  }

  if (DEBUG == 2) {
    printf("\nYou typed: %s\n", input);
  }
  char *result = NULL;
  char *scnl = ";\n"; //semicolon/newline separators
  int fp = NULL; //NULL = STDOUT, anything else is file pointer
  int background = 0; //0 = foreground, 1 = background

  result = strtok(input, scnl);
  while (result != NULL ) {
    //Check for output redirection
    char *gt = ">";
    char *gtexists = strpbrk(result, gt);
    if (gtexists != NULL) {
      //Begin output redirection handler
      printf("GT exists");
      char *redircmd = strdup(result);
      result = strtok(redircmd, gt);
      char *redir = strtok(NULL, gt);
      printf("%s is cmd, %s is redir", result, redir);
    }
    //Check for run in background
    char *amp = "&";
    char *ampexists = strpbrk(result, amp);
    if (ampexists != NULL) {
      printf("AMP exists");
    }
    command_handler(result, fp, background);
    result = strtok(NULL, scnl);
  }
  //Break up on ; into array
  //Go through each complete command, break into args
  //Run command
  return 0;
}

void
command_handler(char *commands, int fp, int background) {
  printf("Your command is: %s\n", commands);
  int i;
  char *output;
  for (i = 0; i < strlen(commands); i++) {
    char c = commands[i];
  }
}

void
error() {
  char error_message[30] = "An error has occurred\n";
  write(STDERR_FILENO, error_message, strlen(error_message));
  exit(1);
}

void
batch() {
  printf("Was batch mode fun?\n");
  exit(1);
}
