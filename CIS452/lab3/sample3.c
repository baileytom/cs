#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define READ 0
#define WRITE 1
#define MAX 1024

int main()
{
    int fd[2];
    ssize_t num;
    pid_t pid;
    char str[MAX];

    if (pipe (fd) < 0) { // Create a pipe
      perror ("plumbing problem");
      exit(1);
    }
// point A

    if ((pid = fork()) < 0) { // Fork, create a child
        perror ("fork failed");
        exit(1);
    }
// point B

    else if (!pid) { // We are a child?
      dup2 (fd[WRITE], STDOUT_FILENO); // Duplicate fd[WRITE] to STDOUT_FILENO
      // ^ Causes the file descriptor STDOUT_FILENO to refer to fd[WRITE]
      // Closes STDOUT_FILENO
      // 
// point C
      close (fd[READ]); // Close the pipe? 
      close (fd[WRITE]); // Close the pipe?
// point D
      fgets (str, MAX, stdin); // Get input
      
      write (STDOUT_FILENO, (const void *) str, (size_t) strlen (str) + 1); // Write to fd[WRITE] into pipe
      
      exit (0);
    }

    dup2 (fd[READ], STDIN_FILENO); // 
// point C
    close (fd[READ]);
    close (fd[WRITE]);
// point D
    num = read (STDIN_FILENO, (void *) str, (size_t)  sizeof (str));
    if (num > MAX) {
        perror ("pipe read error\n");
        exit(1);
    }
    puts (str);
    return 0;
} 
