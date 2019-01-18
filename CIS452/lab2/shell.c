#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SIZE 1024

int printPrompt() {
  printf(" -_- ");
  return 0;
}

int main(int argc, char **argv) {

  while (1) {
    int childPid;
    char cmdLine[MAX_SIZE];

    // Get the input
    printPrompt();
    fgets(cmdLine, MAX_SIZE, stdin);

    // Quit
    if (strcmp(cmdLine, "quit\n") == 0) {
      exit(0);
    }

    // Parser? I hardly know 'er
    char* token = strtok(cmdLine, " ");
    char* args[64];
    int i = 0;
    while (token != NULL) {
      i += 1;
      args[i] = (char*)malloc(sizeof(char)*MAX_SIZE);
      args[i] = token;
      token = strtok(NULL, " ");
    }

    // Strip a tricky newline
    args[i][strcspn(args[i], "\n")] = 0;

    
    args[i+1] = NULL;

    pid_t pid, child;
    int status;
    if ((pid = fork()) < 0) {
      perror("You forked up.");
      exit(1);
    } else if (pid == 0) {
      printf("I am a child.");
      printf(args[0]);
      if (execvp(args[1], &args[1]) < 0) {
      perror("Child failed.");
	exit(1);
      } else {
	exit(0);
      }
    }

    child = wait(&status);

    printf("Child %d returned with status %d", child, status);
    
    
  }
}
