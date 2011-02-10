#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/param.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>

#define MAXINPUT (513) //512 bytes + null
#define MAXCOMMANDS (171) //Should be MAXINPUT/3 (2 letter cmds + ;)
#define DEBUG (1)

int prompt();
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

  result = strtok_r(input, ";\n", &tokptr1);
  while (result != NULL ) {
    //Check for output redirection
    char *command = strdup(result);
    char *gtexists = strpbrk(command, ">");
    if (gtexists != NULL) {
      //Begin output redirection handler
      command = strtok_r(command, ">", &tokptr2);
      char *redir = strtok_r(NULL, ">", &tokptr2);
      *fp = getfp(redir);
      //If there was a file pointer error, set output back to STDOUT
      if (fp < 0) {
        error(1);
        fp = 0;
      }
    }
    
    command_handler(command, fp);
    result = strtok_r(NULL, ";\n", &tokptr1);
  }
  //Break up on ; into array
  //Go through each complete command, break into args
  //Run command
  return 0;
}

void
command_handler(char *commands, int fp) {
  printf("Your command is: %s\n", commands);
  if (fp != 0) {
    printf("File pointer is %d\n", fp);
  }
  
  //REDIR EXAMPLE
  //http://www.cs.loyola.edu/~jglenn/702/S2005/Examples/dup2.html
  
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
      error(1);
    }
  }
  else if (strcmp(arg_list[0], "pwd") == 0) {
    if (i == 0) {
      char *pwd;
      pwd = getcwd(pwd, MAXPATHLEN);
      printf("%s\n", pwd);
	  return;
    }
    else {
      error(1);
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
	wait(NULL);
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
  char *trimmed = strtok(filename, token);
  char *openmode = "O_WRONLY | O_CREAT";
  char *openrights = "S_IWUSR | S_IRUSR";
  int fp = open(trimmed, *openmode, *openrights);
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
}

void
batch(char *batchfile) {
  FILE *file;
  file = fopen(batchfile, "r");
  char input[MAXINPUT];
  while(fgets(input, MAXINPUT, file) != 0) {
	write(STDOUT_FILENO, input, strlen(input));
    parse(input);
  }
}