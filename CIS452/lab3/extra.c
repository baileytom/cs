#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <time.h>

// https://www.linuxprogrammingblog.com/code-examples/sigaction

struct sigaction action;

void handleSig(int sig, siginfo_t *siginfo, void *context);

int main() {
  pid_t pid;
  
  // Spawn off a child process
  if ((pid = fork()) < 0) {
    perror("fork failed");
    exit(1);
  } else if ((pid = fork()) < 0) {
    perror("fork 2 failed");
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
  }
  
  // We're a parent
  //struct sigaction action;
  action.sa_handler = handleSig;
  
  
  while(1) {
    // Catch signals
    sigaction(SIGINT, &action, NULL);
    sigaction(SIGUSR1, &action, NULL);
    sigaction(SIGUSR2, &action, NULL);
    pause();

    
    
  }
  
  return 0;
}

void handleSig(int sig) {
  printf("%d received. ", sig);
  printf("%d\n", action.sa_sigaction.siginfo_t.pid_t);
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
