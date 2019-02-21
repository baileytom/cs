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


#define SIZE 4096

void handleSig();
void* catcher(void* val);

int shmId;
char* shmPtr;
key_t key;

int main()
{
  // create key
  key = ftok("shmfile", 123);
  
  // create shm segment
  if ((shmId = shmget(key, SIZE, IPC_CREAT|S_IRUSR|S_IWUSR)) < 0) {
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

  while (1) {
    // wait here til the shm is not locked
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

    // update reads
    int reads = (int) *shmPtr + 1;
    memcpy(shmPtr, &reads, 1);

    // print line
    printf("%s", *(shmPtr + 1));
  
    // unlock the shm
    if ((shmctl(shmId, SHM_UNLOCK, 0)) < 0) {
      perror("unlocking failed\n");
      exit(1);
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
