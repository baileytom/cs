#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <time.h>

void handleSig(int);

int main() {
  pid_t pid;
  
  // Spawn off a child process
  if ((pid = fork()) < 0) {
    perror("fork failed");
    exit(1);
  } else if (!pid) {
    fflush(stdout);
    // We're a child
    srand(time(NULL));
    int r;
    pid_t ppid = getppid();
    while(1) {
      r = (rand()%5)+1;
      fflush(stdout);
      sleep(r);
      if(r%2==0) {
	kill(ppid, SIGUSR1);
      } else {
	kill(ppid, SIGUSR2);
      }
    }
    exit(0);
  }

  // We're a parent
  fflush(stdout);
  while(1) {
    // Catch signals
    signal(SIGINT, handleSig);
    signal(SIGUSR1, handleSig);
    signal(SIGUSR2, handleSig);
    pause();
  }
  
  return 0;
}

void handleSig(int sig) {
  printf("%d received. ", sig);
  if (sig == SIGINT) {
    printf("Killing myself.\n");
    exit(0);
  } else if (sig == SIGUSR1) {
    printf("SIGUSR1.\n");
  } else if (sig == SIGUSR2) {
    printf("SIGUSR2.\n");
  } else {
    printf("Something is wrong.\n");
  }
  fflush(stdout);
}
