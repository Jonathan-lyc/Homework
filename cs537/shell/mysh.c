#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <assert.h>

#define MAXINPUT (514) //512 bytes + null
#define MAXCOMMANDS (171) //Should be MAXINPUT/3 (2 letter cmds + ;)
#define DEBUG (1)

void prompt();
void error();
void batch(char *batchfile);
void parse();
void command_handler(char *commands, int fp);
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
    batch(argv[1]);
  }
  return 0;
}

void
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
  if (strpbrk(input, "\n") == NULL) {
    error(1);
    return;
  }
  parse(input);
}

void
parse(char *input){
  //Take out newline, turn to null terminated string
  if (input[strlen (input) -1] == '\n') {
    input[strlen (input) - 1] = '\0';
  }

  char *result = NULL;
  int *fp = 0; //0 = STDOUT, anything else is file pointer
  char *tokptr1, *tokptr2;
  int stdoutcopy = 0;
  char *gtexists = NULL;

  result = strtok_r(input, ";\n", &tokptr1);
  while (result != NULL ) {
    //Check for output redirection
    char *command = strdup(result);
    gtexists = strpbrk(command, ">");
    if (gtexists != NULL) {
      //Begin output redirection handler
      dup2(STDOUT_FILENO, stdoutcopy);
      command = strtok_r(command, ">", &tokptr2);
      char *redir = strtok_r(NULL, ">", &tokptr2);
      fp = getfp(redir);
    }
    
    command_handler(command, fp);
    if (gtexists != NULL) {
      close(fp);
      dup2(stdoutcopy, STDOUT_FILENO);
    }
    result = strtok_r(NULL, ";\n", &tokptr1);
  }
  return 0;
}

void
command_handler(char *commands, int fp) {
  //printf("Your command is: %s\n", commands);

  char *tokptr1, *tokptr2;
  //Check for run in background
  char *ampexists = strpbrk(commands, "&");
  int background = 0; //0 = foreground, 1 = background
  if (ampexists != NULL) {
	commands = strtok_r(commands, "&", &tokptr1);
	background = 1;
  }

  //Build args list.
  char *arg_list[MAXCOMMANDS];
  int i=0; //counter
  arg_list[i]=strtok_r(commands," ", &tokptr2);

  while(arg_list[i]!=NULL)
  {
    i++;
    arg_list[i]=strtok_r(NULL," ", &tokptr2);
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
      error(2);
    }
  }
  else if (strcmp(arg_list[0], "pwd") == 0) {
    if (i == 0) {
      char *pwd;
      pwd = getcwd(pwd, MAXPATHLEN);
      int len = strlen(pwd);
      pwd[len] = '\n';
      pwd[len + 1] = '\0';
      write(STDOUT_FILENO, pwd, strlen(pwd));
      return;
    }
    else {
      error(2);
    }
  }
  else if (strcmp(arg_list[0], "cd") == 0) {
    int err = 0;
    if (i == 0) {
      err = chdir(getenv("HOME"));
	  return;
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
    return;
  }
  else if (strcmp(arg_list[0], "waitall") == 0) {
        while (wait(NULL) != -1);
	return;
  }

  int rc = fork();
  if (rc == 0) {
    //child
    execvp(arg_list[0], arg_list);
    //execvp only returns on error
    error(1);
  }
  else if (rc > 0) {
    //parent
    if (background == 0) {
      wait(NULL);
	}
  }
  else {
    error(1);
  }
}

int
getfp(char *filename) {
  char *token = " ";
  char *tokptr;
  char *trimmed = strtok_r(filename, token, &tokptr);
  if (strtok_r(NULL, ">", &tokptr) != NULL) {
    error(1);
    return -1;
  }

  close(STDOUT_FILENO);
  int fp = open(trimmed, O_WRONLY | O_TRUNC | O_CREAT, S_IRUSR | S_IRGRP | S_IWGRP | S_IWUSR);
  if (fp < 0) {
    error(2);
  }
  return fp;
}

// If cont is 0, the shell will exit after printing error message.
void
error(int cont) {
  char error_message[30] = "An error has occurred\n";
  int err = write(STDERR_FILENO, error_message, strlen(error_message));
  if (err < 1) {
    error(1);
  }
  if (cont == 0) {
    exit(1);
  }
  else if (cont == 2){
    exit(0);
  }
}

void
batch(char *batchfile) {
  FILE *file;
  file = fopen(batchfile, "r");
  if (file == NULL) {
    error(0);
  }
  char input[MAXINPUT];
  while(fgets(input, MAXINPUT, file) != 0) {
	  write(STDOUT_FILENO, input, strlen(input));
    if (strpbrk(input, "\n") == NULL) {
      error(1);
    }
    else {
      parse(input);
    }
  }
}
