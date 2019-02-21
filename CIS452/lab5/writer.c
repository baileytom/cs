#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>

// create shared memory segment

// repeatedly accept user input string & write to shared memory

#define SIZE 4096

void handleSig();
void* catcher(void* val);

int shmId;
char* shmPtr;
key_t key;

int main ()
{
  // create key
  key = ftok("shmfile", 123);
  
  // create shm segment
  if ((shmId = shmget(key
		      , SIZE, IPC_CREAT|S_IRUSR|S_IWUSR)) < 0) {
    perror("bad\n");
    exit(1);
  }
  
  // attach pointer to shm segment
  if ((shmPtr = shmat(shmId, 0, 0)) == (void*) -1) {
    perror("bad 2\n");
  }
  
  // ctrl-c handler thread
  pthread_t thread;
  int status;
  if ((status = pthread_create(&thread, NULL, catcher, NULL)) != 0) {
    perror("thread not work\n");
    exit(1);
  }
  
  // begin input loop
  while (1) {
    char *line = NULL;
    size_t len = 0;
    ssize_t read;

    printf("\nType something: ");

    while ((read = getline(&line, &len, stdin)) != -1) {
      if (read > 0) {
	// copy the line to shared memory
	// this is the critical section

	// wait here til the shm is (not?) locked -- mode == 384
	// and while all readers have not displayed the string
	struct shmid_ds stat;
	do {
	  if ((shmctl(shmId, IPC_STAT, &stat)) < 0) {
	    perror("getting stat failed\n");
	    exit(1);
	  }
	  printf("%d -- %d -- %d\n", stat.shm_perm.mode, SHM_LOCKED, (int) *shmPtr);
	} while (stat.shm_perm.mode == SHM_LOCKED);

	// lock the shm
	if ((shmctl(shmId, SHM_LOCK, 0)) < 0) {
	  perror("locking failed\n");
	  exit(1);
	}

	printf("writing mem\n");
	memcpy(shmPtr+1, line, len);
	*(shmPtr+len) = '\0';

	// unlock the shm
	if ((shmctl(shmId, SHM_UNLOCK, 0)) < 0) {
	  perror("unlocking failed\n");
	  exit(1);
	}
      }
    }
  }
}

void* catcher(void* val) {
  while (1) {
    signal(SIGINT, handleSig);
    pause();
  }
}

void handleSig() {
  // detatch
  if (shmdt(shmPtr) < 0) {
    perror("can't detatch\n");
    exit(1);
  }
  // deallocate
  if (shmctl(shmId, IPC_RMID, 0) < 0) {
    perror("can't deallocate\n");
    exit(1);
  }
  exit(0);
}
