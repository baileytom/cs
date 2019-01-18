#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termios.h>

int main() {

  struct termios termAttributes, save;

  // Get term attributes
  tcgetattr(STDIN_FILENO, &termAttributes);
  tcgetattr(STDIN_FILENO, &save);

  // Turn echo off
  //termAttributes.c_lflag &= ~ECHO;
  termAttributes.c_lflag &= ~ICANON;
  tcsetattr(STDIN_FILENO, 0, &termAttributes);

  char pw[256];
  printf("Enter the password: ");
  scanf("%s", &pw);
  printf("\n%s", pw);

  // Restore original settings
  tcsetattr(STDIN_FILENO, 0, &save);

  return 0;
  
  
}
