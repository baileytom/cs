#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sys/resource.h>

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

    // Null terminate
    args[i+1] = NULL;

    // Begin forking
    pid_t pid, child;
    int status;
    if ((pid = fork()) < 0) {
      perror("You forked up.");
      exit(1);
    } else if (pid == 0) {
      printf("I am a child.");
      printf("%s", args[0]);
      if (execvp(args[1], &args[1]) < 0) {
      perror("Child failed.");
	exit(1);
      } else {
	exit(0);
      }
    } else {

      // Get the status
      child = wait(&status);
      long seconds;
      long milsecs;
      int context_switch;
      struct rusage resources;
      if (getrusage(RUSAGE_CHILDREN, &resources) < 0) {
        printf("Failed.");
      } else {
      	seconds = resources.ru_utime.tv_sec;
	milsecs = resources.ru_utime.tv_usec;
	context_switch = resources.ru_nivcsw;
	printf("Child %d returned with status %d.\nCPU time: %ld s %ld ms\nContext switches: %d\n", child, status, seconds, milsecs, context_switch);
      }
    }
  }
  return 0;
}

