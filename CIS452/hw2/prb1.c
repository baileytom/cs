#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>

int main()
{
  for (int i = 0; i < 4; i++) {
    fork();
    int pid = getpid();
    printf("%d, it %d\n", pid, i);
  }
  printf("process here\n");
  wait(NULL);
  return 0;
}
