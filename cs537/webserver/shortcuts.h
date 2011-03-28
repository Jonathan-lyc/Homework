#ifndef __SHORTCUTS_H__
#define __SHORTCUTS_H__

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <errno.h>

// Error handling
void unix_error(char *msg);

// Wrapper functions
// Locks
void Mutex_init(pthread_mutex_t *lock);
void Mutex_lock(pthread_mutex_t *lock);
void Mutex_unlock(pthread_mutex_t *lock);

// Condition variables
void Cond_init();
void Cond_wait(pthread_cond_t *cond, void *lock);
void Cond_signal(pthread_cond_t *cond);

// Thread shortcuts
void Pthread_create(pthread_t *cid, void *func);
void Pthread_join(pthread_t *cid);

// Linked list
struct node {
  struct request *req;
  struct node *next;
  struct node *prev;
};

void ll_append(struct node *n);
void ll_insert(struct node *prev, struct node *after);
void ll_remove(struct node *n);


#endif