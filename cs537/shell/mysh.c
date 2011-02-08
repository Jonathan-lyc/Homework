#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/param.h>

#define MAXINPUT (513) //512 bytes + null
#define MAXCOMMANDS (171) //Should be MAXINPUT/3 (2 letter cmds + ;)
#define DEBUG (1)

int prompt();
void error();
void batch();
void command_handler(char *commands, int fp, int background);
int getfp(char *filename);
int
main(int argc, char *argv[]){
  if (argc > 2) {
    error(0);
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
    error(0);
  }

  printf("mysh> ");
  char *a = fgets(input, MAXINPUT, stdin);
  //Check that fgets didn't have an error.
  if (a == NULL) {
    error(1);
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
  char *tokptr1, *tokptr2;

  result = strtok_r(input, scnl, &tokptr1);
  while (result != NULL ) {
    //Check for output redirection
    char *command = strdup(result);
    char *gt = ">";
    char *gtexists = strpbrk(command, gt);
    if (gtexists != NULL) {
      //Begin output redirection handler
      command = strtok_r(command, gt, &tokptr2);
      char *redir = strtok_r(NULL, gt, &tokptr2);
      fp = getfp(redir);
    }
    //Check for run in background
    char *amp = "&";
    char *ampexists = strpbrk(command, amp);
    if (ampexists != NULL) {
      printf("AMP exists");
    }
    command_handler(command, fp, background);
    result = strtok_r(NULL, scnl, &tokptr1);
  }
  //Break up on ; into array
  //Go through each complete command, break into args
  //Run command
  return 0;
}

void
command_handler(char *commands, int fp, int background) {
  printf("Your command is: %s\n", commands);
  if (fp != 0) {
    printf("File pointer is %d\n", fp);
  }

  //Build args list.
  char *arg_list[MAXCOMMANDS];
  int i=0; //counter
  arg_list[i]=strtok(commands," ");

  while(arg_list[i]!=NULL)
  {
    i++;
    arg_list[i]=strtok(NULL," ");
  }

  //Add required null at end of command for execvp
  arg_list[i] = NULL;
  i--;
  //Builtin command processing
  if (strcmp(arg_list[0], "exit") == 0) {
    if (i == 0) {
      exit(0);
    }
    else {
      error(1);
    }
  }
  else if (strcmp(arg_list[0], "pwd") == 0) {
    if (i == 0) {
      char *pwd;
      pwd = getcwd(pwd, MAXPATHLEN);
      printf("%s\n", pwd);
    }
    else {
      error(1);
    }
  }
  else if (strcmp(arg_list[0], "cd") == 0) {
    int err;
    if (i == 0) {
      printf("here");

      printf("home is %s", getenv("HOME"));
      err = chdir(getenv("HOME"));
    }
    else if (i == 1) {
      err = chdir(arg_list[1]);
    }
    else {
      error(1);
    }
    if (err != 0) {
      error(1);
    }
  }
}

int
getfp(char *filename) {
  char *token = " ";
  char *trimmed = strtok(filename, token);
  int fp = open(trimmed, "O_WRONLY | O_CREAT", "S_IWUSR | S_IRUSR");
  return fp;
}

// If cont is 0, the shell will exit after printing error message.
void
error(int cont) {
  char error_message[30] = "An error has occurred\n";
  write(STDERR_FILENO, error_message, strlen(error_message));
  if (cont == 0) {
    exit(1);
  }
}

void
batch() {
  printf("Was batch mode fun?\n");
  exit(1);
}
