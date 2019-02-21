#include <pthread.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <string>
#include <iostream>
#include <cstring>

void* worker (void* filename);

void handleSig (int);

void* catcher (void* val);

int files_serviced = 0;

int main()
{
  // thread to catch ctrl-C
  pthread_t cthread;
  int cstatus;
  if ((cstatus = pthread_create (&cthread, NULL, catcher, NULL)) != 0) {
    fprintf (stderr, "thread create error %d: %s\n", cstatus, strerror(cstatus));
    exit(1);
  }
  
  // dispatch thread is main
  while (1)
    { 
      pthread_t wthread;
      void *result;
      int status;

      std::string user_input;
      std::cout << "Please type something: ";
      std::cin >> user_input;

      char* cstr = new char [user_input.length()+1];
      std::strcpy (cstr, user_input.c_str());
      
      // spawn worker thread
      if ((status = pthread_create (&wthread, NULL, worker, cstr)) != 0) {
	fprintf (stderr, "thread create error %d: %s\n", status, strerror(status));
	exit(1);
      }
    }
}

void* worker (void* filename) {
  // get that filename before it changes
  char* filename_perm = (char*) filename;
  
  // random sleep
  if (rand()%10 < 2) {
    sleep(1);
  } else {
    sleep(7 + rand()%4);
  }

  // wake up
  printf("We accessed the file called %s\n", filename);
  files_serviced++;
  
  // terminate
  return NULL;
}

void* catcher(void* val) {
  while(1) {
    signal(SIGINT, handleSig);
    pause();
  }
}

void handleSig(int sig) {
  printf("Files serviced: %d", files_serviced);
  exit(0);
}
